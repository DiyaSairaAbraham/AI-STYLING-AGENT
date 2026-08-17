import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(
    const AIStylingApp(),
  );
}

class AIStylingApp extends StatelessWidget {
  const AIStylingApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Personal Styling Consultant',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFF8F5F0),
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF2F2924),
        ),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}