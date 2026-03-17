import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(
        title: 'Settings',
        subtitle: 'Tùy chỉnh ứng dụng theo nhu cầu',
      ),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}
