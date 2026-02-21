// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Maltese (`mt`).
class AppLocalizationsMt extends AppLocalizations {
  AppLocalizationsMt([String locale = 'mt']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Agħżel il-Lingwa';

  @override
  String get signIn => 'Idħol';

  @override
  String get login => 'IDĦOL';

  @override
  String get register => 'IRREĠISTRA';

  @override
  String get forgotPassword => 'Insejt il-password?';

  @override
  String get signUp => 'Irreġistra';

  @override
  String get emailHint => 'ezempju@email.com';

  @override
  String get passwordHint => 'password';

  @override
  String get usernameHint => 'username';

  @override
  String get repeatPasswordHint => 'erġa\' ikteb il-password';

  @override
  String get resetPasswordPrompt =>
      'Daħħal l-email tiegħek biex tirrisettja l-password';

  @override
  String get sendCode => 'Ibgħat il-Kodiċi';

  @override
  String get returnToLogin => 'Mur lura għall-login';

  @override
  String get checkYourEmail => 'Iċċekkja l-Email Tiegħek!';

  @override
  String resetLinkSent(Object email) {
    return 'Bgħatna link għar-risettjar tal-password lil $email';
  }

  @override
  String get enterOtp => 'Daħħal il-kodiċi mill-email tiegħek';

  @override
  String get otpHint => 'kodiċi ta\' 6 ċifri';

  @override
  String get verifyCode => 'Ivverifika l-Kodiċi';

  @override
  String get goBack => 'Mur Lura';

  @override
  String get enterAsGuest => 'Idħol bħala mistieden';

  @override
  String get privacyPolicy => 'Politika tal-Privatezza';

  @override
  String get termsOfUse => 'Termini ta\' Użu';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
