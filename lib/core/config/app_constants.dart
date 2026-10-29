import 'package:flutter/material.dart';

/// Centralised application-wide constants.
///
/// All hard-coded values (app name, version, wake phrases, etc.)
/// live here so they can be changed in a single place.
abstract final class AppConstants {
  // ── Identity ──────────────────────────────────────────────

  /// Display name of the assistant used across all UI and voice surfaces.
  static const String appName = 'D';

  /// Current semantic version string.
  static const String appVersion = '0.1.0';

  /// Build number for store submissions.
  static const int buildNumber = 1;

  // ── Wake Phrases ──────────────────────────────────────────

  /// Primary wake phrase (default-enabled).
  static const String wakePhraseHeyD = 'Hey D';

  /// Short single-syllable wake word (opt-in).
  static const String wakeWordD = 'D';

  // ── Clap Detection ────────────────────────────────────────

  /// Minimum gap between two claps to count as a double-clap (ms).
  static const int clapMinGapMs = 300;

  /// Maximum gap between two claps to count as a double-clap (ms).
  static const int clapMaxGapMs = 800;

  // ── Networking ────────────────────────────────────────────

  /// Base URL for the FastAPI backend (overridden per flavour).
  static const String defaultBaseUrl = 'http://localhost:8000';

  /// HTTP connect timeout (ms).
  static const int connectTimeoutMs = 10000;

  /// HTTP receive timeout (ms).
  static const int receiveTimeoutMs = 30000;

  /// Maximum number of automatic retries on transient failures.
  static const int maxRetries = 3;

  // ── Voice ─────────────────────────────────────────────────

  /// Maximum lines D speaks aloud; longer answers are shown on card.
  static const int maxVoiceResponseLines = 2;

  // ── Supported Locales ─────────────────────────────────────

  /// Locales the app ships translations for.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('gu'),
  ];

  // ── Storage Keys ──────────────────────────────────────────

  /// Secure storage key for the JWT access token.
  static const String keyAccessToken = 'access_token';

  /// Secure storage key for the JWT refresh token.
  static const String keyRefreshToken = 'refresh_token';
}
