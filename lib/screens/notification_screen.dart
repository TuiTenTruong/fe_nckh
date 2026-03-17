import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(
        title: 'Notifications',
        subtitle: 'Cap nhat thong bao moi nhat',
      ),
      body: const Center(child: Text('Notification Screen')),
    );
  }
}
