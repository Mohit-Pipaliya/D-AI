// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'D';

  @override
  String get homeTitle => 'Ready to assist you';

  @override
  String get homeSubtitle => 'Say \"Hey D\" or clap twice';

  @override
  String get activationModes => 'Activation Modes';

  @override
  String get wakePhrase => 'Wake Phrase';

  @override
  String get wakeWord => 'Wake Word';

  @override
  String get doubleClap => 'Double Clap Detection';

  @override
  String get chatTitle => 'D Chat';

  @override
  String get chatHint => 'Ask D anything...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get privacyTitle => 'Privacy & Security';

  @override
  String get onDeviceNotice =>
      'Wake word and clap detection run 100% locally on-device.';

  @override
  String get send => 'Send';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';
}
