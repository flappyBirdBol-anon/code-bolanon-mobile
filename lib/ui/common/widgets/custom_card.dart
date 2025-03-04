import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomCard extends StatelessWidget {
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

  const CustomCard({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isHorizontalCard) {
      if (isLoading) {
        return _buildShimmerCard(isDark);
      }
      return _buildCourseCard(context, isDark, theme);
    }

    // Regular button remains the same
    Widget buttonChild;
    if (isLoading) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? textColor ?? Colors.white,
          ),
          if (text.isNotEmpty) SizedBox(width: spacing),
          if (text.isNotEmpty)
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.w500,
              ),
            ),
        ],
      );
    } else {
      buttonChild = Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return SizedBox(
      height: 200,
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              width: 260,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 180,
                          height: 16,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.grey[200],
                            ),
                            Container(
                              width: 80,
                              height: 14,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, bool isDark, ThemeData theme) {
    return Container(
      width: width ?? 260,
      height: height, // This ensures fixed height
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with fixed height
          Stack(
            children: [
              Container(
                height: 110, // Reduced from 120
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: AssetImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 40,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      )
                    : null,
              ),
              if (lessons != null)
                Positioned(
                  top: 8, // Reduced from 10
                  left: 8, // Reduced from 10
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, // Reduced from 8
                      vertical: 3, // Reduced from 4
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 12, // Reduced from 14
                        ),
                        const SizedBox(width: 3), // Reduced from 4
                        Text(
                          "$lessons Lessons",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9, // Reduced from 10
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Content section with optimized padding
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 8, 12, 8), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize ?? 16, // Reduced from 15
                          fontWeight: fontWeight ?? FontWeight.w600,
                          color: textColor ??
                              (isDark ? Colors.white : Colors.black87),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (instructorName != null)
                        Text(
                          'by $instructorName',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12, // Reduced from 12
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  // Price and rating row
                  Row(
                    children: [
                      if (price != null)
                        Text(
                          price!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            fontSize: 13, // Reduced from 14
                          ),
                        ),
                      const Spacer(),
                      if (rating != null) ...[
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14, // Reduced from 15
                        ),
                        const SizedBox(width: 3), // Reduced from 4
                        Text(
                          rating!.toString(),
                          style: const TextStyle(
                            fontSize: 12, // Reduced from 13
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (reviews != null)
                          Text(
                            ' ($reviews)',
                            style: TextStyle(
                              fontSize: 11, // Reduced from 12
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
