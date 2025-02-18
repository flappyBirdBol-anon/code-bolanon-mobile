import 'package:flutter/material.dart';

class PasswordValidationList extends StatelessWidget {
  final bool hasMinLength;
  final bool hasNumber;
  final bool hasUpperCase;
  final bool hasLowerCase;
  final bool isMatch;

  const PasswordValidationList({
    Key? key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasUpperCase,
    required this.hasLowerCase,
    required this.isMatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValidationItem(
          isValid: hasMinLength,
          text: 'At least 8 characters',
        ),
        _ValidationItem(
          isValid: hasNumber,
          text: 'Contains a number',
        ),
        _ValidationItem(
          isValid: hasUpperCase,
          text: 'Contains uppercase letter',
        ),
        _ValidationItem(
          isValid: hasLowerCase,
          text: 'Contains lowercase letter',
        ),
        _ValidationItem(
          isValid: isMatch,
          text: 'Passwords match',
        ),
      ],
    );
  }
}

class _ValidationItem extends StatelessWidget {
  final bool isValid;
  final String text;

  const _ValidationItem({
    required this.isValid,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
