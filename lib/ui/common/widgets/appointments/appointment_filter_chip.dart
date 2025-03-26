import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;

  const AppointmentFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: GoogleFonts.figtree(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.white : Colors.black87),
      ),
    );
  }
}
