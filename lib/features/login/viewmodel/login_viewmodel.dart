import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_exceptions.dart';

class AuthResult {
  final bool success;
  final bool needsVerification;
  final bool onboardingComplete;
  final bool socialAccountExists;

  AuthResult({
    required this.success,
    this.needsVerification = false,
    this.onboardingComplete = true,
    this.socialAccountExists = false,
  });
}

enum LoginTabState {
  showingLogin,
  showingResetPassword,
  showingCheckEmail,
  showingOtpInput,
}

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  LoginTabState _loginTabState = LoginTabState.showingLogin;
  LoginTabState get loginTabState => _loginTabState;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _registerErrorText;
  String? get registerErrorText => _registerErrorText;
  String? _loginErrorText;
  String? get loginErrorText => _loginErrorText;
  String? _resetPasswordErrorText;
  String? get resetPasswordErrorText => _resetPasswordErrorText;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final otpController = TextEditingController();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoginTabState(LoginTabState state) {
    _loginTabState = state;
    if (state != LoginTabState.showingOtpInput) {
      clearAllFieldsAndErrors();
    }
    notifyListeners();
  }

  void clearAllFieldsAndErrors() {
    emailController.clear();
    passwordController.clear();
    usernameController.clear();
    repeatPasswordController.clear();
    otpController.clear();
    _registerErrorText = null;
    _loginErrorText = null;
    _resetPasswordErrorText = null;
  }

  Future<AuthResult> signIn() async {
    final isFormValid = loginFormKey.currentState?.validate() ?? false;
    if (!isFormValid) return AuthResult(success: false);

    _setLoading(true);
    _loginErrorText = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final isOnboardingComplete = await _authService.isCurrentUserOnboardingComplete();
      _setLoading(false);
      return AuthResult(success: true, onboardingComplete: isOnboardingComplete);
    } on AuthServiceException catch (e) {
      _loginErrorText = e.message;
      _setLoading(false);
      return AuthResult(success: false);
    }
  }

  Future<AuthResult> signUp() async {
    final isFormValid = registerFormKey.currentState?.validate() ?? false;
    if (!isFormValid) return AuthResult(success: false);
    if (passwordController.text != repeatPasswordController.text) {
      _registerErrorText = 'Passwords do not match.';
      notifyListeners();
      return AuthResult(success: false);
    }
    _setLoading(true);
    _registerErrorText = null;
    notifyListeners();
    try {
      final needsVerification = await _authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
      );
      _setLoading(false);
      return AuthResult(success: true, needsVerification: needsVerification, onboardingComplete: false);
    } 
    on EmailInUseAuthException {
      _setLoading(false);
      return AuthResult(success: false, socialAccountExists: true);
    } on AuthServiceException catch (e) {
      _registerErrorText = e.message;
      _setLoading(false);
      return AuthResult(success: false);
    }
  }

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _resetPasswordErrorText = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }
    _setLoading(true);
    _resetPasswordErrorText = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetOtp(email: email);
      _loginTabState = LoginTabState.showingOtpInput;
    } on AuthServiceException catch (e) {
      _resetPasswordErrorText = e.message;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    final email = emailController.text.trim();
    final token = otpController.text.trim();
    if (token.isEmpty) {
      _resetPasswordErrorText = "OTP code cannot be empty.";
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _resetPasswordErrorText = null;
    notifyListeners();
    try {
      await _authService.verifyPasswordResetOtp(email: email, token: token);
      _setLoading(false);
      return true;
    } on AuthServiceException catch (e) {
      _resetPasswordErrorText = e.message;
      _setLoading(false);
      return false;
    }
  }

  Future<AuthResult> _executeSocialSignIn(Future<void> Function() signInMethod) async {
    _setLoading(true);
    _loginErrorText = null;
    notifyListeners();
    try {
      await signInMethod();
      final isOnboardingComplete = await _authService.isCurrentUserOnboardingComplete();
      _setLoading(false);
      return AuthResult(success: true, onboardingComplete: isOnboardingComplete);
    } on AuthServiceException catch (e) {
      _loginErrorText = e.message;
      _setLoading(false);
      return AuthResult(success: false);
    }
  }

  Future<AuthResult> signInWithGoogle() {
    return _executeSocialSignIn(_authService.signInWithGoogle);
  }

  Future<AuthResult> signInWithFacebook() {
    return _executeSocialSignIn(_authService.signInWithFacebook);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    repeatPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
