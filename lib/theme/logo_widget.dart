import 'package:flutter/material.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

/// A widget that displays the Sereine logo
/// Can be customized for different sizes and color schemes
class SereineLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? tagline;

  const SereineLogoWidget({
    Key? key,
    this.size = 80.0,
    this.showText = true,
    this.primaryColor,
    this.secondaryColor,
    this.tagline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primary = primaryColor ?? AppColors.primary;
    final Color secondary = secondaryColor ?? AppColors.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo symbol - brain-shaped leaf
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: BrainLeafPainter(
              primaryColor: primary,
              secondaryColor: secondary,
            ),
          ),
        ),
        
        // App name
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'Sereine',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: primary,
            ),
          ),
          
          // Optional tagline
          if (tagline != null) ...[
            const SizedBox(height: 4),
            Text(
              tagline!,
              style: TextStyle(
                fontSize: size * 0.12,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                color: primary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}

/// Custom painter that draws the brain-shaped leaf logo
class BrainLeafPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  BrainLeafPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint mainPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.03;

    final Paint accentPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final Paint outlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw leaf shape (modified teardrop)
    final Path leafPath = Path()
      ..moveTo(center.dx, center.dy - radius * 1.2)
      ..quadraticBezierTo(
        center.dx + radius * 1.2, center.dy - radius * 0.3,
        center.dx + radius * 0.5, center.dy + radius * 0.5,
      )
      ..quadraticBezierTo(
        center.dx, center.dy + radius * 1.1,
        center.dx - radius * 0.5, center.dy + radius * 0.5,
      )
      ..quadraticBezierTo(
        center.dx - radius * 1.2, center.dy - radius * 0.3,
        center.dx, center.dy - radius * 1.2,
      );

    canvas.drawPath(leafPath, mainPaint);

    // Draw brain-like detail patterns inside the leaf
    final Path brainDetailPath = Path();
    
    // Left hemisphere curve
    brainDetailPath.moveTo(center.dx, center.dy - radius * 0.3);
    brainDetailPath.quadraticBezierTo(
      center.dx - radius * 0.6, center.dy,
      center.dx - radius * 0.3, center.dy + radius * 0.5,
    );
    
    // Right hemisphere curve
    brainDetailPath.moveTo(center.dx, center.dy - radius * 0.3);
    brainDetailPath.quadraticBezierTo(
      center.dx + radius * 0.6, center.dy,
      center.dx + radius * 0.3, center.dy + radius * 0.5,
    );

    // Additional brain folds (left side)
    brainDetailPath.moveTo(center.dx - radius * 0.15, center.dy - radius * 0.6);
    brainDetailPath.quadraticBezierTo(
      center.dx - radius * 0.5, center.dy - radius * 0.4,
      center.dx - radius * 0.4, center.dy - radius * 0.1,
    );

    // Additional brain folds (right side)
    brainDetailPath.moveTo(center.dx + radius * 0.15, center.dy - radius * 0.6);
    brainDetailPath.quadraticBezierTo(
      center.dx + radius * 0.5, center.dy - radius * 0.4,
      center.dx + radius * 0.4, center.dy - radius * 0.1,
    );

    // Leaf vein down the middle
    brainDetailPath.moveTo(center.dx, center.dy - radius * 0.9);
    brainDetailPath.lineTo(center.dx, center.dy + radius * 0.7);

    canvas.drawPath(brainDetailPath, outlinePaint);

    // Add a subtle accent glow at the top of the leaf
    final Paint glowPaint = Paint()
      ..color = secondaryColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final Path glowPath = Path()
      ..moveTo(center.dx, center.dy - radius * 1.1)
      ..quadraticBezierTo(
        center.dx + radius * 0.4, center.dy - radius * 0.7,
        center.dx, center.dy - radius * 0.5,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.4, center.dy - radius * 0.7,
        center.dx, center.dy - radius * 1.1,
      );

    canvas.drawPath(glowPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}