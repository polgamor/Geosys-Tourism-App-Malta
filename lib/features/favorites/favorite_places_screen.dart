import 'package:flutter/material.dart';
import '../../colors.dart';

class FavoritePlacesScreen extends StatelessWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Places'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Your favourite places will be displayed here.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
