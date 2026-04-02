import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/models.dart';
import '../services/team_generator.dart';
import 'fantasy_providers.dart';

final teamGenerationControllerProvider =
    StateNotifierProvider.family<
      TeamGenerationController,
      TeamGenerationState,
      String
    >((ref, matchId) => TeamGenerationController(ref, matchId));

class TeamGenerationController extends StateNotifier<TeamGenerationState> {
  TeamGenerationController(this._ref, this._matchId)
    : super(const TeamGenerationState()) {
    _lineupProcessed = false;
  }

  bool _lineupProcessed = false;

  late final dynamic _ref;
  final String _matchId;

  void setRequestedCount(int count) {
    state = state.copyWith(
      requestedCount: count,
      clearError: true,
      clearWarning: true,
    );
  }

  void setGlobalExposurePercent(double value) {
    state = state.copyWith(
      globalExposurePercent: value,
      clearError: true,
      clearWarning: true,
    );
  }

  void setPlayerExposureOverride({
    required String playerId,
    required double exposurePercent,
  }) {
    state = state.copyWith(
      exposureOverrides: {
        ...state.exposureOverrides,
        playerId: exposurePercent,
      },
      clearError: true,
      clearWarning: true,
    );
  }

  void clearPlayerExposureOverride(String playerId) {
    final nextOverrides = {...state.exposureOverrides}..remove(playerId);
    state = state.copyWith(
      exposureOverrides: nextOverrides,
      clearError: true,
      clearWarning: true,
    );
  }

  void setCaptainLock(String playerId) {
    state = state.copyWith(
      captainLockIds: {...state.captainLockIds, playerId},
      clearError: true,
      clearWarning: true,
    );
  }

  void removeCaptainLock(String playerId) {
    state = state.copyWith(
      captainLockIds: {...state.captainLockIds}..remove(playerId),
      clearError: true,
      clearWarning: true,
    );
  }

  void toggleCaptainLock(String playerId) {
    if (state.captainLockIds.contains(playerId)) {
      removeCaptainLock(playerId);
    } else {
      setCaptainLock(playerId);
    }
  }

  void setCaptainAvoid(String playerId) {
    state = state.copyWith(
      captainAvoidIds: {...state.captainAvoidIds, playerId},
      clearError: true,
      clearWarning: true,
    );
  }

  void removeCaptainAvoid(String playerId) {
    state = state.copyWith(
      captainAvoidIds: {...state.captainAvoidIds}..remove(playerId),
      clearError: true,
      clearWarning: true,
    );
  }

  void toggleCaptainAvoid(String playerId) {
    if (state.captainAvoidIds.contains(playerId)) {
      removeCaptainAvoid(playerId);
    } else {
      setCaptainAvoid(playerId);
    }
  }

  void resetForNewMatch() {
    _lineupProcessed = false;
  }

  void handleLineupAutoGenerate(List<FantasyPlayer> players) async {
    if (_lineupProcessed) return;
    if (players.length < 11) {
      print('[AUTO] skip → insufficient players: ${players.length}');
      return;
    }
    if (state.isGenerating) {
      print('[AUTO] skip → already generating');
      return;
    }
    _lineupProcessed = true;
    print('[AUTO] lineup detected → regenerating (${players.length} players)');
    await Future.delayed(const Duration(seconds: 2));
    generateTeams(players);
  }

  Future<void> generateTeams(List<FantasyPlayer> players) async {
    if (players.isEmpty) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'No players available for team generation',
      );
      return;
    }

    if (players.length < 11) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage:
            'Insufficient players: ${players.length} available, need minimum 11',
      );
      return;
    }

    final safePlayers = List<FantasyPlayer>.from(players);

    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      clearWarning: true,
    );

    try {
      final exposureConfig = _buildExposureConfig(safePlayers);

      final seed = Object.hash(
        _matchId,
        state.requestedCount,
        state.globalExposurePercent.round(),
        buildDeterministicSeed(safePlayers, state.requestedCount),
      );

      final generated = await _ref
          .read(teamGeneratorServiceProvider)
          .generateTeams(
            players: safePlayers,
            requestedCount: state.requestedCount,
            exposureConfig: exposureConfig,
            seed: seed,
          );

      final warning = generated.length < state.requestedCount
          ? 'Only ${generated.length} of ${state.requestedCount} teams were generated because exposure, role, or credit constraints became too tight.'
          : null;

      state = state.copyWith(
        isGenerating: false,
        generatedTeams: generated,
        lastGenerationSeed: seed,
        currentBatchIndex: 0,
        warningMessage: warning,
      );
    } catch (error) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'Team generation failed: $error',
      );
    }
  }

  void nextBatch() {
    if (state.currentBatchIndex >= state.totalBatches - 1) {
      return;
    }
    state = state.copyWith(currentBatchIndex: state.currentBatchIndex + 1);
  }

  void previousBatch() {
    if (state.currentBatchIndex <= 0) {
      return;
    }
    state = state.copyWith(currentBatchIndex: state.currentBatchIndex - 1);
  }

  Future<void> copyTeam(GeneratedTeam team) async {
    await Clipboard.setData(ClipboardData(text: team.toCopyText()));
  }

  Future<void> copyCurrentBatch() async {
    final text = state.currentBatch
        .map((team) => team.toCopyText())
        .join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
  }

  ExposureConfig _buildExposureConfig(List<FantasyPlayer> players) {
    return ExposureConfig.fromPlayers(
      players: players,
      globalExposurePercent: state.globalExposurePercent,
      overrides: state.exposureOverrides,
      captainLockIds: state.captainLockIds,
      captainAvoidIds: state.captainAvoidIds,
    );
  }
}
