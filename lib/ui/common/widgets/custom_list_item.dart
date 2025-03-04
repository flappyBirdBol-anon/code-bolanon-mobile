import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CustomListItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? iconSize;
  final double? spacing;
  final String? instructorName;
  final bool isHorizontalCard;
  final int? itemCount;
  final String? imageUrl;
  final int? lessons;
  final double? rating;
  final int? reviews;
  final String? price;
  final IconData? leadingIcon;
  final String? subtitle;
  final Color? leadingIconBackgroundColor;
  final Color? leadingIconColor;
  final Widget? trailing;
  final bool showDivider;
  final double? indentDivider;
  final bool useTileStyle;

  const CustomListItem({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height = 48.0,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconSize = 18,
    this.spacing = 8,
    this.instructorName,
    this.isHorizontalCard = false,
    this.itemCount = 3,
    this.imageUrl,
    this.lessons,
    this.rating,
    this.reviews,
    this.price,
    this.leadingIcon,
    this.subtitle,
    this.leadingIconBackgroundColor,
    this.leadingIconColor,
    this.trailing,
    this.showDivider = false,
    this.indentDivider = 60,
    this.useTileStyle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return _buildLoadingSkeleton(isDark);
    }

    if (useTileStyle) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: leadingIcon != null
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: leadingIconBackgroundColor ??
                          theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      leadingIcon,
                      color: leadingIconColor ?? theme.primaryColor,
                      size: iconSize,
                    ),
                  )
                : null,
            title: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.w500,
                color: textColor,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  )
                : null,
            trailing: trailing ??
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    onPressed: onPressed,
                  ),
                ),
          ),
        ),
      );
    }

    return Container(
        // ...existing container code...
        );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
