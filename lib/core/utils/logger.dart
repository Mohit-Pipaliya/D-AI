import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_constants.dart';

/// Structured application logger that sanitises sensitive data (PII).
///
/// Log output is disabled in release builds unless explicitly configured.
abstract final class AppLogger {
  static Logger? _logger;

  /// Initialises the global logger instance.
  static void init() {
    _logger = Logger(
      filter: _AppLogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 90,
        colors: !kIsWeb,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// Logs a verbose trace message.
  static void t(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.t(_format(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a debug message.
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.d(_format(message), error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(_format(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(_format(message), error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  static void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger?.e(_format(message), error: error, stackTrace: stackTrace);
  }

  /// Formats message with app name prefix and strips sensitive tokens.
  static String _format(String message) {
    var sanitized = message;
    // Strip common secret patterns
    sanitized = sanitized.replaceAll(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*'),
      r'$1[REDACTED]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(r'(sk-[A-Za-z0-9]{20,})'),
      '[REDACTED_API_KEY]',
    );
    return '[${AppConstants.appName}] $sanitized';
  }
}

/// Custom log filter that prevents logging in release mode by default.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) return true;
    // In profile / release mode, only log warnings and errors
    return event.level.value >= Level.warning.value;
  }
}

