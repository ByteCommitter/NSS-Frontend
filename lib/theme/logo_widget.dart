import 'package:flutter/material.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

/// A widget that displays the NSS logo
/// Can be customized for different sizes and color schemes
class NSSLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? tagline;

  const NSSLogoWidget({
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NSS Logo from assets
        Image.asset(
          'assets/images/NSS.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        
        // App name
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'NSS',
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