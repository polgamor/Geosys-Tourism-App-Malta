import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geosys_app/colors.dart';
import 'package:geosys_app/data/services/auth_service.dart';
import 'package:geosys_app/features/login/screens/login_screen.dart';
import 'package:geosys_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:geosys_app/features/map/map_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) => _redirect());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _redirect() async {
    // Brief delay to ensure the Supabase session is updated after an OAuth redirect.
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      final isOnboardingComplete = await _authService.isCurrentUserOnboardingComplete();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              isOnboardingComplete ? const MapScreen() : const OnboardingScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
