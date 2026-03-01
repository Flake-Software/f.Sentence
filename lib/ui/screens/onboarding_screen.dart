import 'dart:math';
import 'dart:ui';
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

  late final AnimationController _bgController =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat(reverse: true);

  final List<_Step> _steps = [
    _Step(
      title: "Import DOCX",
      description: "Open and extract text instantly.",
    ),
    _Step(
      title: "Clean Reading",
      description: "Distraction-free layout.",
    ),
    _Step(
      title: "Start Reading",
      description: "Open your first document.",
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
    _bgController.dispose();
    super.dispose();
  }

  bool get _isLast => _page.round() == _steps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (_, __) {
          return Stack(
            children: [
              /// Animated liquid background
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiquidPainter(
                    progress: _bgController.value,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                ),
              ),

              /// Page content
              PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                itemBuilder: (_, index) {
                  final step = _steps[index];
                  final diff = (_page - index);
                  final opacity = (1 - diff.abs()).clamp(0.0, 1.0);

                  return Opacity(
                    opacity: opacity,
                    child: Center(
                      child: _GlassPanel(step: step),
                    ),
                  );
                },
              ),

              /// Floating magnetic button
              Positioned(
                bottom: 60,
                right: 32,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: _isLast ? 1.2 : 1),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: FloatingActionButton(
                        onPressed: _next,
                        child: Icon(
                          _isLast
                              ? Icons.check
                              : Icons.arrow_forward,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Liquid background painter
class _LiquidPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _LiquidPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.3 + 0.1 * sin(progress * pi)),
      size.width,
      size.height * 0.3,
    );
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    paint.color = colors[0];
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * (0.7 - 0.1 * cos(progress * pi)),
      size.width,
      size.height * 0.7,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    paint.color = colors[1];
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Glass style panel
class _GlassPanel extends StatelessWidget {
  final _Step step;

  const _GlassPanel({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.title,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String title;
  final String description;

  _Step({required this.title, required this.description});
}