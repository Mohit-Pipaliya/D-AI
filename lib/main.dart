import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'app.dart';

/// Application bootstrap entry point.
///
/// Sets up error boundaries, initialises core services,
/// and launches the root [DApp] widget inside a [ProviderScope].
void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialise structured logger.
      AppLogger.init();

      // Resolve build flavour from environment.
      AppConfig.init();

      AppLogger.i('Starting app in ${AppConfig.flavor.name} mode');

      // Global Flutter error handler — catches widget-layer exceptions.
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.e(
          'Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      runApp(
        const ProviderScope(
          child: DApp(),
        ),
      );
    },
    // Catches async errors that escape the Flutter framework.
    (Object error, StackTrace stack) {
      AppLogger.e(
        'Unhandled async error',
        error: error,
        stackTrace: stack,
      );
    },
  );
}
