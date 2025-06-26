import 'package:flutter/material.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Event Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Plan and manage your market events and vendor lineups.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}