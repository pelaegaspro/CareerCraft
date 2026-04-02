import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env_config.dart';

final envConfigProvider = Provider<EnvConfig>((ref) {
  EnvConfig.loadSync(); // add static loadSync if needed, or call in main
  return EnvConfig._();
});

final configSummaryProvider = Provider<Map<String, String>>((ref) {
  return EnvConfig.getConfigSummary();
});
