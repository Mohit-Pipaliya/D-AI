import 'package:flutter/services.dart';

import '../core/utils/logger.dart';

/// Central gateway for platform channels across macOS, Android, Windows, and iOS.
abstract final class PlatformChannels {
  /// Method channel for OS-level background service and automation.
  static const MethodChannel mainChannel =
      MethodChannel('com.d.assistant/main');

  /// Event channel for audio level visualization and microphone streaming status.
  static const EventChannel audioEventChannel =
      EventChannel('com.d.assistant/audio_events');

  /// Requests a platform capability or action.
  static Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      return await mainChannel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e, st) {
      AppLogger.e('Platform channel error on $method: ${e.message}',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// Check whether the platform supports always-on background listening.
  static Future<bool> isBackgroundListeningSupported() async {
    final result = await invokeMethod<bool>('isBackgroundListeningSupported');
    return result ?? false;
  }
}
