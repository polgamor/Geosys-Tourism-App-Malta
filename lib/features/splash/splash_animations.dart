import 'package:flutter/material.dart';

class SplashAnimations {
  final AnimationController pulseController;
  late final Animation<double> pulseAnimation;

  SplashAnimations(TickerProvider vsync)
      : pulseController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 950), 
        ) {
    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> startAnimations() async {
    if (pulseController.isAnimating || pulseController.isCompleted) return;

    await pulseController.forward();
    await pulseController.reverse();
  }

  void dispose() {
    pulseController.dispose();
  }
}