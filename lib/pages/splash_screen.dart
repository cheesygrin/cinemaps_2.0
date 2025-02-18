import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/cinemaps_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoScale;
  late Animation<double> _glowRadius;
  late Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();
    
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Glow effect controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo rotation animation
    _logoRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutBack,
    ));

    // Logo scale animation
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Glow radius animation
    _glowRadius = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Text slide animation
    _textSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: Stack(
        children: [
          // Animated background grid
          _buildAnimatedGrid(),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _glowController]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _logoRotation.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CinemapsTheme.hotPink.withOpacity(0.5),
                                blurRadius: _glowRadius.value,
                                spreadRadius: _glowRadius.value / 2,
                              ),
                              BoxShadow(
                                color: CinemapsTheme.neonYellow.withOpacity(0.3),
                                blurRadius: _glowRadius.value * 1.5,
                                spreadRadius: _glowRadius.value / 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.movie,
                            size: 100,
                            color: CinemapsTheme.hotPink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Animated text
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: 1 - _textSlide.value / 50,
                        child: Column(
                          children: [
                            Text(
                              'CINEMAPS',
                              style: TextStyle(
                                color: CinemapsTheme.neonYellow,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: CinemapsTheme.hotPink.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: CinemapsTheme.neonYellow.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'WHERE MOVIES COME TO LIFE',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: CinemapsTheme.hotPink.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid() {
    return CustomPaint(
      painter: GridPainter(
        animation: _logoController,
      ),
      size: Size.infinite,
    );
  }
}

class GridPainter extends CustomPainter {
  final Animation<double> animation;

  GridPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CinemapsTheme.electricPurple.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const spacing = 50.0;
    final animationValue = animation.value;

    // Draw vertical lines
    for (var i = 0; i <= size.width / spacing; i++) {
      final x = i * spacing;
      final startY = size.height * (1 - animationValue);
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (var i = 0; i <= size.height / spacing; i++) {
      final y = i * spacing;
      final startX = size.width * (1 - animationValue);
      canvas.drawLine(
        Offset(startX, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;
} 