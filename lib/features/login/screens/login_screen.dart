import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'new_password_screen.dart';
import '../../map/map_screen.dart';
import '../viewmodel/login_viewmodel.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../../webview_screen.dart';
import '../../widgets/language_picker_widget.dart';

// Importa las traducciones
import 'package:geosys_app/localization/generated/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToMapScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  void _navigateToOnboardingScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: onConfirm,
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login_background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.65)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildHeaderTitle(),
                          const SizedBox(height: 10),
                          _buildTabBar(context, viewModel),
                          Expanded(
                            child: _buildTabBarView(context, viewModel),
                          ),
                          const SizedBox(height: 10),
                          _buildFooter(context),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 40,
                  right: 15,
                  child: LanguagePickerWidget(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Roboto'),
        children: const <TextSpan>[
          TextSpan(text: 'MALTA', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'GO', style: TextStyle(color: Color.fromARGB(255, 29, 168, 64))),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: TabBar(
          onTap: (index) {
            if (index == 0) {
              viewModel.setLoginTabState(LoginTabState.showingLogin);
            } else {
              viewModel.clearAllFieldsAndErrors();
            }
          },
          indicator: BoxDecoration(color: Colors.black.withOpacity(0.65)),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(child: Text(loc.login)),
            Tab(child: Text(loc.register)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, LoginViewModel viewModel) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)),
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLoginTab(context, viewModel),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: _buildRegisterForm(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context, LoginViewModel viewModel) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
      child: SingleChildScrollView(
        key: ValueKey<LoginTabState>(viewModel.loginTabState),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: _buildLoginTabContent(context, viewModel),
      ),
    );
  }

  Widget _buildLoginTabContent(BuildContext context, LoginViewModel viewModel) {
    switch (viewModel.loginTabState) {
      case LoginTabState.showingLogin:
        return _buildLoginForm(context, viewModel);
      case LoginTabState.showingResetPassword:
        return _buildResetPasswordForm(context, viewModel);
      case LoginTabState.showingCheckEmail:
        return _buildCheckEmailView(context, viewModel);
      case LoginTabState.showingOtpInput:
        return _buildOtpForm(context, viewModel);
    }
  }

  Widget _buildLoginForm(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Form(
      key: viewModel.loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOldStyledTextField(hintText: loc.emailHint, controller: viewModel.emailController, isLoading: viewModel.isLoading, validator: Validators.email),
          const SizedBox(height: 15),
          _buildOldStyledTextField(hintText: loc.passwordHint, obscureText: true, controller: viewModel.passwordController, isLoading: viewModel.isLoading, validator: Validators.password),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: viewModel.isLoading ? null : () => viewModel.setLoginTabState(LoginTabState.showingResetPassword),
              child: Text(loc.forgotPassword, style: TextStyle(color: viewModel.isLoading ? Colors.grey : Colors.white.withOpacity(0.9), fontSize: 12)),
            ),
          ),
          if (viewModel.loginErrorText != null) _buildErrorText(viewModel.loginErrorText!),
          _buildOldAuthButton(
            text: loc.signIn,
            isLoading: viewModel.isLoading,
            onPressed: () async {
              final result = await viewModel.signIn();
              if (result.success && context.mounted) {
                result.onboardingComplete ? _navigateToMapScreen(context) : _navigateToOnboardingScreen(context);
              }
            },
          ),
          const SizedBox(height: 10),
          _buildSeparator(),
          const SizedBox(height: 10),
          _buildOldSocialButtons(context, viewModel),
          _buildGuestButton(context, viewModel),
        ],
      ),
    );
  }

  void _showSocialAccountExistsDialog(BuildContext context,TabController tabController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: const Text('Email Already Registered', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This email is already in use, possibly with a Google or Facebook account. Please log in instead.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              tabController.animateTo(0);
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Form(
      key: viewModel.registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOldStyledTextField(hintText: loc.usernameHint, controller: viewModel.usernameController, isLoading: viewModel.isLoading, validator: Validators.name),
          const SizedBox(height: 15),
          _buildOldStyledTextField(hintText: loc.emailHint, controller: viewModel.emailController, isLoading: viewModel.isLoading, validator: Validators.email),
          const SizedBox(height: 15),
          _buildOldStyledTextField(hintText: loc.passwordHint, obscureText: true, controller: viewModel.passwordController, isLoading: viewModel.isLoading, validator: Validators.password),
          const SizedBox(height: 15),
          _buildOldStyledTextField(hintText: loc.repeatPasswordHint, obscureText: true, controller: viewModel.repeatPasswordController, isLoading: viewModel.isLoading, validator: (value) => Validators.confirmPassword(value, viewModel.passwordController.text)),
          const SizedBox(height: 15),
          if (viewModel.registerErrorText != null) _buildErrorText(viewModel.registerErrorText!),
          _buildOldAuthButton(
            text: loc.signUp,
            isLoading: viewModel.isLoading,
              onPressed: () async {
              final result = await viewModel.signUp();
              if (!context.mounted) return;
              if (result.socialAccountExists) {
                if (!context.mounted) return;
                final tabController = DefaultTabController.of(context);
                _showSocialAccountExistsDialog(context, tabController);
              } 
              else if (result.success) {
                if (result.needsVerification) {
                  _showInfoDialog(context, loc.accountCreated, loc.verifyAccountPrompt, () => Navigator.of(context).pop());
                } else {
                  _navigateToOnboardingScreen(context);
                }
              }
            },
          ),
          const SizedBox(height: 10),
          _buildSeparator(),
          const SizedBox(height: 10),
          _buildOldSocialButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildResetPasswordForm(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.resetPasswordPrompt, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        _buildOldStyledTextField(hintText: loc.emailHint, controller: viewModel.emailController, isLoading: viewModel.isLoading),
        const SizedBox(height: 20),
        if (viewModel.resetPasswordErrorText != null)
          _buildErrorText(viewModel.resetPasswordErrorText!),
        _buildOldAuthButton(
          text: loc.sendCode,
          isLoading: viewModel.isLoading,
          onPressed: viewModel.sendPasswordReset,
        ),
        TextButton(
          onPressed: viewModel.isLoading ? null : () => viewModel.setLoginTabState(LoginTabState.showingLogin),
          child: Text(loc.returnToLogin, style: TextStyle(color: viewModel.isLoading ? Colors.grey : Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildCheckEmailView(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.email_outlined, color: Colors.white, size: 80),
        const SizedBox(height: 20),
        Text(loc.checkYourEmail, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(loc.resetLinkSent(viewModel.emailController.text), style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 25),
        TextButton(
          onPressed: viewModel.isLoading ? null : () => viewModel.setLoginTabState(LoginTabState.showingLogin),
          child: Text(loc.returnToLogin, style: TextStyle(color: viewModel.isLoading ? Colors.grey : Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildOtpForm(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(loc.enterOtp, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        _buildOldStyledTextField(hintText: 'Email', controller: viewModel.emailController, enabled: false, isLoading: viewModel.isLoading),
        const SizedBox(height: 15),
        _buildOldStyledTextField(hintText: loc.otpHint, controller: viewModel.otpController, keyboardType: TextInputType.number, isLoading: viewModel.isLoading),
        const SizedBox(height: 20),
        if (viewModel.resetPasswordErrorText != null)
          _buildErrorText(viewModel.resetPasswordErrorText!),
        _buildOldAuthButton(
          text: loc.verifyCode,
          isLoading: viewModel.isLoading,
          onPressed: () async {
            if (await viewModel.verifyOtp()) {
              final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => const NewPasswordScreen()));
              if (result == true && context.mounted) {
                viewModel.setLoginTabState(LoginTabState.showingLogin);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green));
              }
            }
          },
        ),
        TextButton(
          onPressed: viewModel.isLoading ? null : () => viewModel.setLoginTabState(LoginTabState.showingResetPassword),
          child: Text(loc.goBack, style: TextStyle(color: viewModel.isLoading ? Colors.grey : Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildOldStyledTextField({
    required String hintText,
    bool obscureText = false,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    required bool isLoading,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled && !isLoading,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(color: enabled ? Colors.black87 : Colors.grey.shade600, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade300,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }

  Widget _buildOldAuthButton({required String text, required VoidCallback? onPressed, required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
  
  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildOldSocialButtons(BuildContext context, LoginViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading ? null : () async {
              final result = await viewModel.signInWithGoogle();
              if (result.success && context.mounted) {
                result.onboardingComplete ? _navigateToMapScreen(context) : _navigateToOnboardingScreen(context);
              }
            },
            icon: const Icon(Icons.g_mobiledata, color: Colors.black),
            label: Text('Google', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading
              ? null
              : () async { 
                  final result = await viewModel.signInWithFacebook(); 
                  if (result.success && context.mounted) { 
                    result.onboardingComplete
                        ? _navigateToMapScreen(context)
                        : _navigateToOnboardingScreen(context);
                  }
                },
            icon: const Icon(Icons.facebook, color: Colors.white),
            label: const Text('Facebook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestButton(BuildContext context, LoginViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: viewModel.isLoading ? null : () => _navigateToMapScreen(context),
      child: Text(loc.enterAsGuest, style: TextStyle(color: viewModel.isLoading ? Colors.grey : Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const privacyPolicyUrl = 'https://polgamor.github.io/politic-privacy-user-data/privacypolicy.html';
    const termsUrl = 'https://polgamor.github.io/politic-privacy-user-data/termsandconditions.html';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WebViewScreen(
                title: loc.privacyPolicy,
                url: privacyPolicyUrl,
              ),
            ));
          },
          child: Text(
            loc.privacyPolicy,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text('|', style: TextStyle(color: Colors.white.withOpacity(0.8))),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WebViewScreen(
                title: loc.termsOfUse,
                url: termsUrl,
              ),
            ));
          },
          child: Text(
            loc.termsOfUse,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty.';
    }
    return null;
  }
}