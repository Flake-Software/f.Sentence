import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _animController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.description_outlined,
      title: 'Import DOCX files',
      description:
          'Open your .docx files and extract readable text in just a few taps.',
    ),
    _OnboardingStep(
      icon: Icons.chrome_reader_mode_outlined,
      title: 'Read with less clutter',
      description:
          'View document text in a clean, focused layout that is easy to follow.',
    ),
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

  bool get _isLastPage => _currentPage == _steps.length - 1;

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextPage() {
    if (_isLastPage) {
      _goToHome();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildStep(_OnboardingStep step, bool active) {
    final theme = Theme.of(context);
    return AnimatedScale(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      scale: active ? 1.0 : 0.9,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: active ? 1.0 : 0.6,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: active ? null : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animController.forward(from: 0);
                },
                itemBuilder: (_, index) {
                  return _buildStep(_steps[index], index == _currentPage);
                },
              ),
            ),
            const SizedBox(height: 20),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: index == _currentPage ? 28 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(100, 48),
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(140, 48),
                    ),
                    child: Text(_isLastPage ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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