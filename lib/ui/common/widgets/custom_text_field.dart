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
        style: style ?? theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          errorStyle: GoogleFonts.figtree(
            color: theme.colorScheme.error,
            fontSize: 12,
            height: 1.4,
            wordSpacing: 0.5,
          ),
          errorMaxLines: 5,
          helperMaxLines: 5,
          floatingLabelStyle: GoogleFonts.figtree(
            color:
                errorText != null ? theme.colorScheme.error : AppColors.primary,
          ),
          isDense: isDense,
          filled: filled,
          fillColor: fillColor ??
              (isDark ? const Color.fromARGB(255, 100, 82, 82) : Colors.white),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: errorText != null
                      ? theme.colorScheme.error
                      : AppColors.primary.withOpacity(0.7),
                  size: 24,
                )
              : prefix,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: errorText != null
                        ? theme.colorScheme.error
                        : AppColors.primary.withOpacity(0.7),
                    size: 24,
                  ),
                  onPressed: onToggleVisibility,
                )
              : suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : (borderColor ??
                      (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : (borderColor ??
                      (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorText != null
                  ? theme.colorScheme.error
                  : (focusedBorderColor ?? AppColors.primary),
              width: 2.5,
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
          contentPadding: contentPadding ??
              const EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: 18,
              ),
          labelStyle: labelStyle ??
              GoogleFonts.figtree(
                color: errorText != null
                    ? theme.colorScheme.error
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                fontSize: 16,
              ),
          hintStyle: hintStyle ??
              GoogleFonts.figtree(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 15,
              ),
        ),
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}
