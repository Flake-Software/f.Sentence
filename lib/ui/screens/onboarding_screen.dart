import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  double _drag = 0;

  final List<_Step> _steps = [
    _Step(
      title: "Import DOCX",
      description: "Extract text from your documents instantly.",
    ),
    _Step(
      title: "Clean Reading",
      description: "Focus only on what matters.",
    ),
    _Step(
      title: "Start Reading",
      description: "Open your first document now.",
    ),
  ];

  bool get _isLast => _index == _steps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      setState(() {
        _index++;
        _drag = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_index];

    final dragProgress = (_drag / -200).clamp(0.0, 1.0);

    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _drag += details.delta.dy * 0.9; // soft resistance
          });
        },
        onVerticalDragEnd: (_) {
          if (_drag < -120) {
            _next();
          } else {
            setState(() => _drag = 0);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          color: theme.colorScheme.surface,
          child: Stack(
            children: [
              /// Next layer (soft fade in)
              if (!_isLast)
                Opacity(
                  opacity: dragProgress * 0.4,
                  child: _LayerContent(step: _steps[_index + 1]),
                ),

              /// Current layer
              Transform.translate(
                offset: Offset(0, _drag),
                child: Opacity(
                  opacity: 1 - dragProgress,
                  child: _LayerContent(step: step),
                ),
              ),

              /// Subtle bottom hint
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 0.4,
                  child: Center(
                    child: Text(
                      "Swipe to continue",
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayerContent extends StatelessWidget {
  final _Step step;

  const _LayerContent({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              step.title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              step.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String title;
  final String description;

  _Step({
    required this.title,
    required this.description,
  });
}