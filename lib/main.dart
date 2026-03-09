import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart'; 

void main() {
  runApp(const FSentenceApp());
}

class FSentenceApp extends StatelessWidget {
  const FSentenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'f.Sentence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // Direct access to HomeScreen to avoid "Onboarding" errors
      home: const HomeScreen(), 
    );
  }
}
