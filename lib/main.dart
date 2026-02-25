import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/document_viewer_screen.dart';

void main() {
  runApp(const FSentenceApp());
}

class FSentenceApp extends StatefulWidget {
  const FSentenceApp({super.key});

  @override
  State<FSentenceApp> createState() => _FSentenceAppState();
}

class _FSentenceAppState extends State<FSentenceApp> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool('first_launch') ?? true;

    if (firstLaunch) {
      await prefs.setBool('first_launch', false);
    }

    setState(() {
      _isFirstLaunch = firstLaunch;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstLaunch == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: _isFirstLaunch!
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
