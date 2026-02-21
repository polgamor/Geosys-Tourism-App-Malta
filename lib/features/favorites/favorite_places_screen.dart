import 'package:flutter/material.dart';
import '../../colors.dart';

class FavoritePlacesScreen extends StatelessWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitios Favoritos'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán tus sitios favoritos.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
