import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomScheduleItem extends StatelessWidget {
  final String date;
  final String startTime;
  final String endTime;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final bool isDark;
  final bool isBook;
  final String id;

  const CustomScheduleItem({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.onTap,
    this.onReschedule,
    this.onCancel,
    required this.isDark,
    required this.isBook,
    required this.id,
  });

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReschedule != null)
              ListTile(
                leading: Icon(
                  Icons.edit_calendar,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
                title: Text(
                  'Reschedule',
                  style: GoogleFonts.figtree(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onReschedule!();
                },
              ),
            if (onCancel != null)
              ListTile(
                leading: Icon(
                  Icons.cancel_outlined,
                  color: isDark ? Colors.redAccent : Colors.red,
                ),
                title: Text(
                  'Cancel Schedule',
                  style: GoogleFonts.figtree(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onCancel!();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time_outlined,
                    color: isDark ? Colors.white : Colors.blue[700],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$startTime - $endTime",
                        style: GoogleFonts.figtree(
                          color: isDark ? Colors.white : Colors.grey[800],
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          date,
                          style: GoogleFonts.figtree(
                            color: isDark ? Colors.white70 : Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                isBook
                    ? ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.white : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'Book',
                          style: GoogleFonts.figtree(
                            color: isDark ? AppColors.primary : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _showOptionsBottomSheet(context),
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
