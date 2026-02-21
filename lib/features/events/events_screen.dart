import 'package:flutter/material.dart';
import '../../colors.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los eventos.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}