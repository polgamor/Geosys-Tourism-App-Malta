// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get login => 'ANMELDEN';

  @override
  String get register => 'REGISTRIEREN';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get signUp => 'Registrieren';

  @override
  String get emailHint => 'beispiel@email.com';

  @override
  String get passwordHint => 'passwort';

  @override
  String get usernameHint => 'benutzername';

  @override
  String get repeatPasswordHint => 'passwort wiederholen';

  @override
  String get resetPasswordPrompt =>
      'Gib deine E-Mail-Adresse ein, um dein Passwort zurückzusetzen';

  @override
  String get sendCode => 'Code senden';

  @override
  String get returnToLogin => 'Zurück zum Login';

  @override
  String get checkYourEmail => 'Überprüfe deine E-Mails!';

  @override
  String resetLinkSent(Object email) {
    return 'Wir haben einen Link zum Zurücksetzen des Passworts an $email gesendet';
  }

  @override
  String get enterOtp => 'Gib den Code aus deiner E-Mail ein';

  @override
  String get otpHint => '6-stelliger Code';

  @override
  String get verifyCode => 'Code überprüfen';

  @override
  String get goBack => 'Zurück';

  @override
  String get enterAsGuest => 'Als Gast eintreten';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
