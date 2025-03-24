import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppointmentItem extends StatelessWidget {
  final String learnerName;
  final String date;
  final String startTime;
  final String endTime;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onReschedule;
  final VoidCallback onPostpone;
  final bool isDark;

  const CustomAppointmentItem({
    super.key, // Changed from key: key to super.key
    required this.learnerName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.onTap,
    required this.onReschedule,
    required this.onPostpone,
    required this.isDark,
  }); // Removed : super(key: key)

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
                    color: isCompleted
                        ? (isDark
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF10B981).withOpacity(0.1))
                        : (isDark
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.video_camera_front_outlined,
                    color: isCompleted
                        ? (isDark
                            ? Colors.greenAccent[200]
                            : const Color(0xFF10B981))
                        : (isDark ? Colors.white : Colors.blue[700]),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        learnerName,
                        style: GoogleFonts.figtree(
                          color: isDark ? Colors.white : Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
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
                                color:
                                    isDark ? Colors.white70 : Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$startTime - $endTime",
                            style: GoogleFonts.figtree(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white : Colors.blue[700],
                    size: 16,
                  ),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[200],
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onReschedule,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_repeat,
                            size: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reschedule',
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.grey[800]!.withOpacity(0.3)
                        : Colors.grey[200],
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onPostpone,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: isDark ? Colors.red[400] : Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Postpone',
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.red[400] : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
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
}
