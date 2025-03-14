import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

class CustomStackChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool isDark;
  final IconData? icon;
  final double? width;
  final Color? color;
  final bool isOutlined;
  final TextStyle? textStyle;

  const CustomStackChip({
    Key? key,
    required this.label,
    this.onTap,
    this.selected = false,
    this.isDark = false,
    this.icon,
    this.width,
    this.color,
    this.isOutlined = true,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).primaryColor;
    final effectiveTextStyle = textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                    ? AppColors.primary.withOpacity(0.2)
                    : defaultColor.withOpacity(0.1))
                : isOutlined
                    ? Colors.transparent
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: isOutlined
                ? Border.all(
                    color: selected
                        ? AppColors.primary.withOpacity(isDark ? 0.5 : 0.3)
                        : Colors.grey.withOpacity(0.5),
                    width: 1,
                  )
                : null,
            boxShadow: isOutlined
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? (isDark
                          ? AppColors.primary.withOpacity(0.9)
                          : AppColors.primary)
                      : Colors.grey[600],
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: effectiveTextStyle?.copyWith(
                  color: selected
                      ? (isDark
                          ? AppColors.primary.withOpacity(0.9)
                          : AppColors.primary)
                      : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
