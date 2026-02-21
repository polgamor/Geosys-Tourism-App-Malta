import 'package:flutter/material.dart';
import '../../colors.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Events will be displayed here.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
