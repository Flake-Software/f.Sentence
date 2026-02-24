import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/home.dart';
import 'ui/screens/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(FSentenceApp(seenOnboarding: seenOnboarding));
}

class FSentenceApp extends StatelessWidget {
  final bool seenOnboarding;
  const FSentenceApp({required this.seenOnboarding, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'f.Sentence',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      initialRoute: seenOnboarding ? '/main' : '/onboarding',
      routes: {
        '/main': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}