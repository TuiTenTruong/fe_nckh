// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'scan_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return const ScanScreen();
  }
}
