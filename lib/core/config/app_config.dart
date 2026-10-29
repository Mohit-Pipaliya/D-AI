import 'app_constants.dart';

/// Build flavour / environment for the application.
enum AppFlavor {
  /// Local development with verbose logging.
  dev,

  /// Production release with minimal logging.
  prod,
}

/// Runtime application configuration resolved from compile-time
/// environment variables.
///
/// Call [AppConfig.init] once during bootstrap before any other
/// config access.
abstract final class AppConfig {
  static AppFlavor _flavor = AppFlavor.dev;

  /// The active build flavour.
  static AppFlavor get flavor => _flavor;

  /// Whether the app is running in development mode.
  static bool get isDev => _flavor == AppFlavor.dev;

  /// Whether the app is running in production mode.
  static bool get isProd => _flavor == AppFlavor.prod;

  /// Base URL for the backend API, resolved per flavour.
  static String get baseUrl {
    const envUrl = String.fromEnvironment('BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    return switch (_flavor) {
      AppFlavor.dev => AppConstants.defaultBaseUrl,
      AppFlavor.prod => 'https://api.d-ai.app',
    };
  }

  /// Initialises configuration from environment declarations.
  ///
  /// Reads `FLAVOR` from `--dart-define` and falls back to [AppFlavor.dev].
  static void init() {
    const envFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    _flavor = switch (envFlavor.toLowerCase()) {
      'prod' || 'production' => AppFlavor.prod,
      _ => AppFlavor.dev,
    };
  }
}
