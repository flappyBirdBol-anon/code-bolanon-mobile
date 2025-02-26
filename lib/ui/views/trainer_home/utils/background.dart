import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrystallineBackground extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final bool animate;
  final double opacity; // Add opacity control

  const CrystallineBackground({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFECF0F3),
    this.animate = true,
    this.opacity = 0.3, // Default subtle transparency
  }) : super(key: key);

  @override
  State<CrystallineBackground> createState() => _CrystallineBackgroundState();
}

class _CrystallineBackgroundState extends State<CrystallineBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    if (!widget.animate) {
      _controller1.stop();
      _controller2.stop();
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive colors based on theme with transparency
    final baseColor = widget.baseColor.withOpacity(widget.opacity);
    final accentColor = isDark
        ? const Color(0xFF2C3E50).withOpacity(widget.opacity * 0.7)
        : const Color(0xFFE0F7FA).withOpacity(widget.opacity * 0.7);
    final highlightColor = isDark
        ? const Color(0xFF34495E).withOpacity(widget.opacity * 0.8)
        : Colors.white.withOpacity(widget.opacity * 0.8);

    return Stack(
      children: [
        // Base gradient background with transparency
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                baseColor.withOpacity(widget.opacity * 0.8),
                isDark
                    ? baseColor.withOpacity(widget.opacity * 0.6)
                    : baseColor.withOpacity(widget.opacity * 0.4),
                accentColor.withOpacity(widget.opacity * 0.2),
              ],
            ),
          ),
        ),

        // Crystal patterns with more transparency
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: CrystalPainter(
                animation: _controller1.value,
                isDark: isDark,
                baseColor: baseColor,
                highlightColor:
                    highlightColor.withOpacity(widget.opacity * 0.7),
              ),
            );
          },
        ),

        // Crystal facets with transparency
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Stack(
              children: [
                // Large crystal facet top right
                Positioned(
                  top: -100 + (_controller2.value * 20),
                  right: -100,
                  child: Transform.rotate(
                    angle: 0.2 - (_controller2.value * 0.05),
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          colors: [
                            highlightColor.withOpacity(widget.opacity * 0.15),
                            highlightColor.withOpacity(widget.opacity * 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color:
                              highlightColor.withOpacity(widget.opacity * 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Medium crystal facet bottom left
                Positioned(
                  bottom: -80 + (_controller1.value * 15),
                  left: -60,
                  child: Transform.rotate(
                    angle: -0.3 + (_controller1.value * 0.08),
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            highlightColor.withOpacity(widget.opacity * 0.15),
                            highlightColor.withOpacity(widget.opacity * 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(80),
                        border: Border.all(
                          color:
                              highlightColor.withOpacity(widget.opacity * 0.25),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Small crystal facet mid-right
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  right: -30 + (_controller2.value * 10),
                  child: Transform.rotate(
                    angle: 0.6 - (_controller2.value * 0.1),
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomLeft,
                          colors: [
                            highlightColor.withOpacity(widget.opacity * 0.2),
                            highlightColor.withOpacity(widget.opacity * 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              highlightColor.withOpacity(widget.opacity * 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Subtle crystal dust effect - reduced opacity
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                isDark
                    ? Colors.black.withOpacity(widget.opacity * 0.03)
                    : Colors.white.withOpacity(widget.opacity * 0.08),
                Colors.transparent,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(rect);
          },
          blendMode: BlendMode.screen,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),

        // Main content
        widget.child,
      ],
    );
  }
}

class CrystalPainter extends CustomPainter {
  final double animation;
  final bool isDark;
  final Color baseColor;
  final Color highlightColor;

  CrystalPainter({
    required this.animation,
    required this.isDark,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw subtle crystal lines with lower opacity
    final linePaint = Paint()
      ..color = highlightColor.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw some geometric crystal shapes
    for (int i = 0; i < 10; i++) {
      double x = width * (0.1 + (i * 0.08)) + (animation * 5);
      double y = height * 0.2 * math.sin(i * 0.5 + animation);

      final path = Path();
      path.moveTo(x, y);
      path.lineTo(x + 30, y + 50);
      path.lineTo(x + 70, y + 20);
      path.lineTo(x + 40, y - 30);
      path.close();

      canvas.drawPath(path, linePaint);
    }

    // Draw reflective crystal edges with lower opacity
    final edgePaint = Paint()
      ..color = highlightColor.withOpacity(0.1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      double startX = width * 0.1 * i;
      double startY = height * (0.3 + 0.1 * i) + (animation * 10);
      double endX = startX + width * 0.2;
      double endY = startY - height * 0.15;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        edgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CrystalPainter oldDelegate) => true;
}
