// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get signIn => 'Accedi';

  @override
  String get login => 'ACCEDI';

  @override
  String get register => 'REGISTRATI';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get signUp => 'Registrati';

  @override
  String get emailHint => 'esempio@email.com';

  @override
  String get passwordHint => 'password';

  @override
  String get usernameHint => 'nome utente';

  @override
  String get repeatPasswordHint => 'ripeti password';

  @override
  String get resetPasswordPrompt =>
      'Inserisci la tua email per reimpostare la password';

  @override
  String get sendCode => 'Invia Codice';

  @override
  String get returnToLogin => 'Torna al login';

  @override
  String get checkYourEmail => 'Controlla la tua Email!';

  @override
  String resetLinkSent(Object email) {
    return 'Abbiamo inviato un link per il reset della password a $email';
  }

  @override
  String get enterOtp => 'Inserisci il codice dalla tua email';

  @override
  String get otpHint => 'codice a 6 cifre';

  @override
  String get verifyCode => 'Verifica Codice';

  @override
  String get goBack => 'Torna Indietro';

  @override
  String get enterAsGuest => 'Entra come ospite';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get termsOfUse => 'Termini di Utilizzo';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
