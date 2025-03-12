import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Get color based on tech stack tag
  (Color bgColor, Color textColor) _getTagColors() {
    switch (tag.toLowerCase()) {
      case 'flutter':
        return (const Color(0xFFE7F5FF), const Color(0xFF0175C2));
      case 'react':
        return (const Color(0xFFE6F6FF), const Color(0xFF61DAFB));
      case 'node.js':
        return (const Color(0xFFE7F7E7), const Color(0xFF539E43));
      case 'python':
        return (const Color(0xFFFFEFB7), const Color(0xFF306998));
      case 'javascript':
        return (const Color(0xFFFFF3DC), const Color(0xFFF7DF1E));
      case 'typescript':
        return (const Color(0xFFE7F5FF), const Color(0xFF3178C6));
      case 'web dev':
        return (const Color(0xFFFFE7E7), const Color(0xFFE44D26));
      case 'mobile dev':
        return (const Color(0xFFFFE0F4), const Color(0xFFD6358C));
      case 'data science':
        return (const Color(0xFFE7F5FF), const Color(0xFF2196F3));
      case 'devops':
        return (const Color(0xFFE7EEFF), const Color(0xFF0F52BA));
      case 'machine learning':
        return (const Color(0xFFE8F5E9), const Color(0xFF4CAF50));
      case 'ui/ux':
        return (const Color(0xFFF3E5F5), const Color(0xFF9C27B0));
      case 'frontend':
        return (const Color(0xFFFFF3E0), const Color(0xFFFF9800));
      case 'backend':
        return (const Color(0xFFE8EAF6), const Color(0xFF3F51B5));
      case 'full stack':
        return (const Color(0xFFEFEBE9), const Color(0xFF795548));
      case 'cloud':
        return (const Color(0xFFE1F5FE), const Color(0xFF03A9F4));
      case 'database':
        return (const Color(0xFFE8F5E9), const Color(0xFF43A047));
      case 'api':
        return (const Color(0xFFFFEBEE), const Color(0xFFE53935));
      default:
        return (const Color(0xFFEEEEEE), const Color(0xFF757575));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _getTagColors();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor ?? bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? textColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: GoogleFonts.firaCode(
              color: labelColor ?? textColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
