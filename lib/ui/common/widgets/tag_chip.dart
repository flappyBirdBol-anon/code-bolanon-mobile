import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? labelColor;

  const TagChip({
    Key? key,
    required this.tag,
    this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.labelColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: labelColor ?? theme.primaryColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
