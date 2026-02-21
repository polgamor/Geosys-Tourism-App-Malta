import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    // Inmediatamente después de que el widget se construya,
    // redirigimos al usuario a la pantalla correcta.
    // El 'addPostFrameCallback' evita errores de 'setState' durante la construcción.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });

    // Escuchamos cualquier cambio futuro en el estado de autenticación.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _redirect();
    });
  }

  @override
  void dispose() {
    // Es importante cancelar la suscripción para evitar fugas de memoria.
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _redirect() async {
    // Esperamos un breve momento para asegurar que la sesión de Supabase esté actualizada
    // después de la redirección de OAuth.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return; // Si el widget ya no está en pantalla, no hacemos nada.

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Si no hay sesión, vamos a la pantalla de Login.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      // Si hay sesión, verificamos si el onboarding está completo.
      final isOnboardingComplete = await _authService.isCurrentUserOnboardingComplete();
      if (!mounted) return;

      if (isOnboardingComplete) {
        // Si está completo, vamos al mapa.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MapScreen()),
          (route) => false,
        );
      } else {
        // Si no, vamos a la pantalla de Onboarding.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Este widget solo muestra una pantalla de carga inicial
    // mientras la lógica de redirección se ejecuta.
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 29, 168, 64),
        ),
      ),
    );
  }
}