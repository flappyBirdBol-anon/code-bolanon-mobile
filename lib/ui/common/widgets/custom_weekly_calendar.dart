import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomWeeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime> weekDays;
  final List<String> weekdays;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final Function(BuildContext) onCalendarTap;
  final bool isDark;

  const CustomWeeklyCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.weekDays,
    required this.weekdays,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCalendarTap,
    required this.isDark,
  }) : super(key: key);

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [AppColors.primary.withOpacity(0.95), AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousWeek,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d').format(weekDays.last)}',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => onCalendarTap(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onNextWeek,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = weekDays[index];
                final isToday = _isToday(date);
                final isSelected = _isSameDay(date, selectedDate);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            weekdays[index],
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                                  .withOpacity(isSelected || isToday ? 1 : 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isSelected || isToday
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: GoogleFonts.figtree(
                                  fontSize: 16,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isToday
                                      ? AppColors.primary
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
