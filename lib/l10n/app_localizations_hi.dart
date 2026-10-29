// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'डी';

  @override
  String get homeTitle => 'आपकी सहायता के लिए तैयार';

  @override
  String get homeSubtitle => '\"हे डी\" कहें या दो बार ताली बजाएं';

  @override
  String get activationModes => 'सक्रियण मोड';

  @override
  String get wakePhrase => 'वेक वाक्यांश';

  @override
  String get wakeWord => 'वेक शब्द';

  @override
  String get doubleClap => 'डबल क्लैप डिटेक्शन';

  @override
  String get chatTitle => 'डी चैट';

  @override
  String get chatHint => 'डी से कुछ भी पूछें...';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get privacyTitle => 'गोपनीयता और सुरक्षा';

  @override
  String get onDeviceNotice =>
      'वेक वर्ड और क्लैप डिटेक्शन पूरी तरह से आपके डिवाइस पर चलते हैं।';

  @override
  String get send => 'भेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';
}
