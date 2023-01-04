import 'package:flutter/material.dart';
import 'eSenseDice.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rolling Dice',
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home: const ESenseDice()
    );
  }
}
