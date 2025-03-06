import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CustomAppointmentList extends StatelessWidget {
  final String contextDetails;
  final String startAt;
  final String endAt;
  final String? price;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? customColor;
  final int? studentsEnrolled; // Optional - only for trainer view
  final bool isTrainerView; // New property to determine view type

  const CustomAppointmentList({
    Key? key,
    required this.contextDetails,
    required this.startAt,
    required this.endAt,
    this.price,
    required this.onTap,
    this.isLoading = false,
    this.customColor,
    this.studentsEnrolled,
    this.isTrainerView = false, // Default to learner view
  }) : super(key: key);

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day + 1) {
      return 'Tomorrow';
    }

    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(String start, String end) {
    final startTime = DateTime.parse(start);
    final endTime = DateTime.parse(end);
    final duration = endTime.difference(startTime);
    return '${duration.inMinutes} minutes';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(isDark ? 0.3 : 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.video_camera_front_outlined,
                  color: isDark ? Colors.white : Colors.indigo[700],
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contextDetails,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white : Colors.indigo[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(startAt)} at ${_formatTime(startAt)} • ${_calculateDuration(startAt, endAt)}',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.indigo[700],
                        fontSize: 13,
                      ),
                    ),
                    if (price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '₱$price',
                        style: GoogleFonts.inter(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : Colors.indigo[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isTrainerView)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? Colors.white : Colors.indigo[700],
                    ),
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
          if (isTrainerView) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: isDark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.indigo[700],
                ),
                const SizedBox(width: 8),
                Text(
                  '${studentsEnrolled ?? 0} students enrolled',
                  style: GoogleFonts.inter(
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.indigo[700],
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white.withOpacity(0.2) : Colors.white,
                    foregroundColor: isDark ? Colors.white : Colors.indigo[700],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Session',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
