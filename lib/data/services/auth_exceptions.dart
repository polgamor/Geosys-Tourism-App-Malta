// Excepción base para todos los errores de autenticación
class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

// Errores específicos de Sign In
class InvalidCredentialsAuthException extends AuthServiceException {
  InvalidCredentialsAuthException() : super('Incorrect email or password.');
}

class EmailNotConfirmedAuthException extends AuthServiceException {
  EmailNotConfirmedAuthException() : super('Please verify your email first.');
}

// Errores específicos de Sign Up
class EmailInUseAuthException extends AuthServiceException {
  EmailInUseAuthException() : super('An account with this email already exists.');
}

class WeakPasswordAuthException extends AuthServiceException {
  WeakPasswordAuthException() : super('Password must be at least 6 characters long.');
}

// Nuevo error para username duplicado
class UsernameInUseAuthException extends AuthServiceException {
  UsernameInUseAuthException() : super('This username is already taken. Please choose another one.');
}

// Errores de Password Reset
class UserNotFoundAuthException extends AuthServiceException {
  UserNotFoundAuthException() : super('User not found with this email.');
}

class InvalidOtpAuthException extends AuthServiceException {
  InvalidOtpAuthException() : super('The code has expired or is invalid.');
}

// Error genérico para casos inesperados
class GenericAuthException extends AuthServiceException {
  GenericAuthException() : super('An unexpected error occurred. Please try again.');
}