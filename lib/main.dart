import 'package:flutter/material.dart';

void main() => runApp(const TakaApp());

class const TakaApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Taka',
      home: Scaffold(body: Center(child: Text('Taka'))),
    );
  }
}
