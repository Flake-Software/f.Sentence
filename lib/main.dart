import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  double _page = 0;

  late final AnimationController _blobController =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat(reverse: true);

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

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _blobController.dispose();
    super.dispose();
  }

  bool get _isLast => _page.round() == _steps.length - 1;

  void _finish() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _blobController,
        builder: (_, __) {
          return Stack(
            children: [
              /// Blobby background
              Positioned.fill(
                child: CustomPaint(
                  painter: _BlobPainter(
                    progress: _blobController.value,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.15),
                      theme.colorScheme.secondary.withOpacity(0.12),
                    ],
                  ),
                ),
              ),

              /// PageView
              PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                itemBuilder: (_, index) {
                  final step = _steps[index];
                  final diff = _page - index;
                  final opacity = (1 - diff.abs()).clamp(0.0, 1.0);
                  final translate = diff * 40;

                  return Transform.translate(
                    offset: Offset(translate, 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Center(
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
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onPageChanged: (i) {
                  if (i == _steps.length - 1) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_isLast) _finish();
                    });
                  }
                },
              ),

              /// Subtle bottom hint
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.35,
                    child: Text(
                      "Swipe to continue",
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Blob Painter
class _BlobPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _BlobPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(size.width * 0.2, size.height * 0.3);
    path1.cubicTo(
      size.width * (0.1 + 0.05 * sin(progress * pi)),
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.4,
    );
    path1.cubicTo(
      size.width * 0.8,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.5,
    );
    path1.close();

    paint.color = colors[0];
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.8, size.height * 0.7);
    path2.cubicTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.8,
    );
    path2.cubicTo(
      size.width * 0.4,
      size.height * 0.95,
      size.width * 0.9,
      size.height * 0.95,
      size.width * 0.8,
      size.height * 0.7,
    );
    path2.close();

    paint.color = colors[1];
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Step {
  final String title;
  final String description;

  _Step({required this.title, required this.description});
}