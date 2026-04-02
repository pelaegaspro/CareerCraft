import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class that manages all environment variables and API credentials.
/// This class provides a centralized, type-safe way to access configuration values.
///
/// SECURITY NOTE:
/// - Do NOT use this for sensitive production secrets (API keys, private tokens)
/// - Flutter apps are client-side; .env is NOT secure in APK/EXE
/// - For production: Use backend (Firebase, Supabase edge functions, Node.js)
/// - This is suitable for: base URLs, feature flags, debug configs
class EnvConfig {
  // Prevent instantiation
  EnvConfig._();

  /// Initialize environment variables from .env file
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file might not exist in production; fall back to empty config
      print('⚠ Warning: Could not load .env file: $e');
    }
  }

  /// Validate that all required configuration values are present
  /// Throws an exception if critical config is missing
  static void validate() {
    final missing = <String>[];

    if (_getValue('SUPABASE_URL')?.isEmpty ?? true) {
      missing.add('SUPABASE_URL');
    }
    if (_getValue('SUPABASE_ANON_KEY')?.isEmpty ?? true) {
      missing.add('SUPABASE_ANON_KEY');
    }
    if (_getValue('CRICAPI_API_KEY')?.isEmpty ?? true) {
      missing.add('CRICAPI_API_KEY');
    }
    if (_getValue('PREMIUM_FEED_API_KEY')?.isEmpty ?? true) {
      missing.add('PREMIUM_FEED_API_KEY');
    }

    if (missing.isNotEmpty) {
      throw ConfigurationException(
        'Missing required environment variables: ${missing.join(", ")}\n'
        'Check your .env file or set these in your environment.',
      );
    }
  }

  /// Get a configuration value (returns null if not set)
  static String? _getValue(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  // ==================== Supabase Configuration ====================

  /// Supabase project URL
  /// Required for app initialization
  static String get supabaseUrl {
    final value = _getValue('SUPABASE_URL');
    if (value == null) {
      throw ConfigurationException(
        'SUPABASE_URL not set. Check your .env file.',
      );
    }
    return value;
  }

  /// Supabase anonymous key for client-side operations
  /// Required for authenticated API calls
  static String get supabaseAnonKey {
    final value = _getValue('SUPABASE_ANON_KEY');
    if (value == null) {
      throw ConfigurationException(
        'SUPABASE_ANON_KEY not set. Check your .env file.',
      );
    }
    return value;
  }

  // ==================== CricAPI Configuration ====================

  /// Base URL for CricAPI endpoint
  static String get cricapiBaseUrl {
    return _getValue('CRICAPI_BASE_URL') ?? 'https://api.cricapi.com/v1/';
  }

  /// API key for CricAPI authentication
  /// ⚠ WARNING: This is exposed in the app bundle
  /// For production: Use backend relay instead
  static String get cricapiApiKey {
    final value = _getValue('CRICAPI_API_KEY');
    if (value == null) {
      throw ConfigurationException(
        'CRICAPI_API_KEY not set. Check your .env file.',
      );
    }
    return value;
  }

  // ==================== SportRadar Premium Feed Configuration ====================

  /// Base URL for SportRadar Premium Cricket Feed
  static String get premiumFeedBaseUrl {
    return _getValue('PREMIUM_FEED_BASE_URL') ??
        'https://api.sportradar.com/cricket-t2/en/';
  }

  /// API key for SportRadar Premium Feed authentication
  /// ⚠ WARNING: This is exposed in the app bundle
  /// For production: Use backend relay instead
  static String get premiumFeedApiKey {
    final value = _getValue('PREMIUM_FEED_API_KEY');
    if (value == null) {
      throw ConfigurationException(
        'PREMIUM_FEED_API_KEY not set. Check your .env file.',
      );
    }
    return value;
  }

  // ==================== Configuration Summary ====================

  /// Get a summary of the loaded configuration (without exposing sensitive keys)
  /// Safe for logging/debugging - only shows ✓ or ✗, never shows actual values
  static Map<String, String> getConfigSummary() {
    return {
      'SUPABASE_URL': _getValue('SUPABASE_URL') != null ? '✓' : '✗',
      'SUPABASE_ANON_KEY': _getValue('SUPABASE_ANON_KEY') != null ? '✓' : '✗',
      'CRICAPI_BASE_URL': _getValue('CRICAPI_BASE_URL') != null ? '✓' : '✗',
      'CRICAPI_API_KEY': _getValue('CRICAPI_API_KEY') != null ? '✓' : '✗',
      'PREMIUM_FEED_BASE_URL': _getValue('PREMIUM_FEED_BASE_URL') != null
          ? '✓'
          : '✗',
      'PREMIUM_FEED_API_KEY': _getValue('PREMIUM_FEED_API_KEY') != null
          ? '✓'
          : '✗',
    };
  }
}

/// Custom exception for configuration errors
class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => '🔴 ConfigurationException: $message';
}
