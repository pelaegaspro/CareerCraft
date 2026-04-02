import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

abstract class AuthService {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> signIn(String email);
  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      return _mapUser(event.session?.user ?? _client.auth.currentUser);
    });
  }

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Future<void> signIn(String email) async {
    await _client.auth.signInWithOtp(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.id,
      isAnonymous: false,
      displayName: user.userMetadata?['display_name']?.toString(),
      email: user.email,
    );
  }
}
