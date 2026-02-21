import 'package:flutter/material.dart';
import 'package:geosys_app/data/services/auth_gate.dart'; 
import 'splash_animations.dart';
import 'splash_widgets.dart';
import 'splash_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final SplashAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = SplashAnimations(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animations.startAnimations();
      }
    });

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    
    if (!mounted) return;

    navigateToScreen(context, const AuthGate());
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF009929), Color(0xFF5CCB5F)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _animations.pulseController,
                builder: (context, child) {
                  return AnimatedLogo(
                    scaleAnimation: _animations.pulseAnimation,
                  );
                },
              ),
            ),
            const FooterText(),
          ],
        ),
      ),
    );
  }
}