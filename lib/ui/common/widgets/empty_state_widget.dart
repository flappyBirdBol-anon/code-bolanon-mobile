import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  /// The animation asset path (Lottie or regular animation)
  final String animationPath;

  /// Title to display below the animation
  final String title;

  /// Optional description
  final String? description;

  /// Optional action button text
  final String? buttonText;

  /// Callback when button is pressed
  final VoidCallback? onActionPressed;

  /// Animation size
  final double animationSize;

  /// Is dark mode enabled
  final bool? isDark;

  const EmptyStateWidget({
    Key? key,
    required this.animationPath,
    required this.title,
    this.description,
    this.buttonText,
    this.onActionPressed,
    this.animationSize = 200,
    this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        isDark ?? Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation
            SizedBox(
              height: animationSize,
              width: animationSize,
              child: Lottie.asset(
                animationPath,
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),

            // Description (if provided)
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button (if provided)
            if (buttonText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
