import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/new_password_viewmodel.dart'; 

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPasswordViewModel(),
      child: Consumer<NewPasswordViewModel>(
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: viewModel.passwordController,
                          hintText: 'New Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: viewModel.confirmPasswordController,
                          hintText: 'Confirm New Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              viewModel.errorText!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 10),
                        viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : _buildAuthButton(
                                text: 'Save Password',
                                onPressed: () async {
                                  if (await viewModel.updatePassword()) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // COMENTARIO:
  // Widgets de UI extraídos para mantener la consistencia con LoginScreen.
  Widget _buildHeader() {
    return const Text(
      "Create New Password",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87, decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }

  Widget _buildAuthButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}