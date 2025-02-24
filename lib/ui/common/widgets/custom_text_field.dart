import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.onToggleVisibility,
    this.focusNode,
    this.onFocusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
      ),
    );
  }
}
