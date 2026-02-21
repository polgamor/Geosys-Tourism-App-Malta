// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get signIn => 'Sign In';

  @override
  String get login => 'LOGIN';

  @override
  String get register => 'REGISTER';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordHint => 'password';

  @override
  String get usernameHint => 'username';

  @override
  String get repeatPasswordHint => 'repeat password';

  @override
  String get resetPasswordPrompt => 'Enter your email to reset your password';

  @override
  String get sendCode => 'Send Code';

  @override
  String get returnToLogin => 'Return to login';

  @override
  String get checkYourEmail => 'Check Your Email!';

  @override
  String resetLinkSent(Object email) {
    return 'We sent a password reset link to $email';
  }

  @override
  String get enterOtp => 'Enter the code from your email';

  @override
  String get otpHint => '6-digit code';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get goBack => 'Go Back';

  @override
  String get enterAsGuest => 'Enter as guest';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
