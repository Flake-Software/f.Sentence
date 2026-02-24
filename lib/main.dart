import 'package:flutter/material.dart';
import 'ui/screens/home.dart';
import 'ui/screens/onboarding.dart';

void main() {
  runApp(const FSentenceApp());
}

class FSentenceApp extends StatelessWidget {
  const FSentenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'f.Sentence',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto', // tvoj izbor
      ),
      initialRoute: '/onboarding',
      routes: {
        '/main': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}