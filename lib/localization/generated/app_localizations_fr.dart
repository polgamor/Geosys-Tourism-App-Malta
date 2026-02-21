// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get login => 'CONNEXION';

  @override
  String get register => 'S\'INSCRIRE';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get passwordHint => 'mot de passe';

  @override
  String get usernameHint => 'nom d\'utilisateur';

  @override
  String get repeatPasswordHint => 'répéter le mot de passe';

  @override
  String get resetPasswordPrompt =>
      'Entrez votre e-mail pour réinitialiser votre mot de passe';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get returnToLogin => 'Retour à la connexion';

  @override
  String get checkYourEmail => 'Vérifiez votre e-mail !';

  @override
  String resetLinkSent(Object email) {
    return 'Nous avons envoyé un lien de réinitialisation du mot de passe à $email';
  }

  @override
  String get enterOtp => 'Entrez le code de votre e-mail';

  @override
  String get otpHint => 'code à 6 chiffres';

  @override
  String get verifyCode => 'Vérifier le code';

  @override
  String get goBack => 'Retour';

  @override
  String get enterAsGuest => 'Entrer en tant qu\'invité';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
