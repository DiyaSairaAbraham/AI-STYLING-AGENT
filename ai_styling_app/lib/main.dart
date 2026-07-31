import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AIStylingApp());
}

class AIStylingApp extends StatelessWidget {
  const AIStylingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AI Styling Agent",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}