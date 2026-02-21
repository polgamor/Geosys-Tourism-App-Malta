import 'package:flutter/material.dart';
import 'package:geosys_app/data/services/auth_exceptions.dart';
import 'package:geosys_app/data/services/auth_service.dart';

class NewPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> updatePassword() async {
    if (passwordController.text.length < 6) {
      _errorText = 'Password must be at least 6 characters long.';
      notifyListeners();
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _errorText = 'The passwords do not match.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorText = null;
    notifyListeners();

    try {
      await _authService.updateUserPassword(passwordController.text);
      _setLoading(false);
      return true;
    } on AuthServiceException catch (e) {
      _errorText = e.message;
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}