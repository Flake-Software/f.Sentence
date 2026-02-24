import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigacija ka HomeScreen
            Navigator.pushNamed(context, '/main');
          },
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}