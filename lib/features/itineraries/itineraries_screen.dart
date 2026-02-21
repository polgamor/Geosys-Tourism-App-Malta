import 'package:flutter/material.dart';
import '../../colors.dart';

class ItinerariesScreen extends StatelessWidget {
  const ItinerariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itineraries'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Your itineraries will be displayed here.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
