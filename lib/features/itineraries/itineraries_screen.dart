import 'package:flutter/material.dart';
import '../../colors.dart';

class ItinerariesScreen extends StatelessWidget {
  const ItinerariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerarios'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los itinerarios.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
