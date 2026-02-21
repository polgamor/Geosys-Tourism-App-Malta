// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MaltaGO';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get login => 'INICIAR SESIÓN';

  @override
  String get register => 'REGISTRARSE';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signUp => 'Registrarse';

  @override
  String get emailHint => 'ejemplo@email.com';

  @override
  String get passwordHint => 'contraseña';

  @override
  String get usernameHint => 'nombre de usuario';

  @override
  String get repeatPasswordHint => 'repetir contraseña';

  @override
  String get resetPasswordPrompt =>
      'Introduce tu email para reiniciar tu contraseña';

  @override
  String get sendCode => 'Enviar Código';

  @override
  String get returnToLogin => 'Volver a iniciar sesión';

  @override
  String get checkYourEmail => '¡Revisa tu Email!';

  @override
  String resetLinkSent(Object email) {
    return 'Hemos enviado un enlace para reiniciar la contraseña a $email';
  }

  @override
  String get enterOtp => 'Introduce el código de tu email';

  @override
  String get otpHint => 'código de 6 dígitos';

  @override
  String get verifyCode => 'Verificar Código';

  @override
  String get goBack => 'Volver Atrás';

  @override
  String get enterAsGuest => 'Entrar como invitado';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get verifyAccountPrompt =>
      'Please check your email to verify your account before logging in.';
}
