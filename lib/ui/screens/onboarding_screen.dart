import 'package:flutter/material.dart';

import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  static const List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.text_snippet_outlined,
      title: 'Extract text from .docx',
      description:
          'Open documents directly in the app and instantly parse their content.',
    ),
    _OnboardingStep(
      icon: Icons.auto_awesome,
      title: 'Focus on sentences',
      description:
          'Keep reading clear and simple with sentence-first viewing experience.',
    ),
    _OnboardingStep(
      icon: Icons.rocket_launch_outlined,
      title: 'Ready to start',
      description:
          'Continue to your home screen and open your first document.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToHome,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    final step = _steps[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            step.icon,
                            size: 46,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) {
                    final selected = index == _currentPage;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: selected ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (isLastPage) {
                    _goToHome();
                    return;
                  }

                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                  );
                },
                child: Text(isLastPage ? 'Get started' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
