import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(
        title: 'Detail',
        subtitle: 'Thong tin chi tiet mon an',
      ),
      body: const Center(child: Text('Detail Screen')),
    );
  }
}
