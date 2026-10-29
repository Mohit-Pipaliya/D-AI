import 'package:flutter_test/flutter_test.dart';
import 'package:d_ai/core/utils/logger.dart';

void main() {
  group('AppLogger', () {
    test('initialises without error', () {
      expect(() => AppLogger.init(), returnsNormally);
    });

    test('logs trace, debug, info, warn, and error without exceptions', () {
      AppLogger.init();
      expect(() => AppLogger.t('Trace message'), returnsNormally);
      expect(() => AppLogger.d('Debug message'), returnsNormally);
      expect(() => AppLogger.i('Info message'), returnsNormally);
      expect(() => AppLogger.w('Warning message'), returnsNormally);
      expect(() => AppLogger.e('Error message'), returnsNormally);
    });
  });
}
