import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool isDense;
  final bool filled;
  final String? errorText;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.onToggleVisibility,
    this.focusNode,
    this.onFocusChange,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.isDense = false,
    this.filled = true,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        style: style ??
            theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 16), // Increased font size
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          floatingLabelStyle: GoogleFonts.figtree(),
          isDense: isDense,
          filled: filled,
          fillColor: fillColor ?? (isDark ? Colors.grey[900] : Colors.white),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 24, // Larger icon size
                )
              : prefix,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary.withOpacity(0.7),
                    size: 24, // Larger icon size
                  ),
                  onPressed: onToggleVisibility,
                )
              : suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: borderColor ??
                  (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: borderColor ??
                  (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              width: 1.5, // Slightly thicker border
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: focusedBorderColor ?? AppColors.primary,
              width: 2.5, // Thicker focused border
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 2.5,
            ),
          ),
          // Increased vertical padding for larger field height
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          labelStyle: labelStyle ??
              GoogleFonts.figtree(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 16, // Larger label font
              ),
          hintStyle: hintStyle ??
              GoogleFonts.figtree(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 15, // Larger hint font
              ),
        ),
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}
