import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Primer navigacije nazad na onboarding
            Navigator.pushNamed(context, '/onboarding');
          },
          child: const Text('Go to Onboarding'),
        ),
      ),
    );
  }
}