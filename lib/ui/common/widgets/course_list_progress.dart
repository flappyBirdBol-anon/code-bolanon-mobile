import 'package:flutter/material.dart';

class CourseListProgress extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String registrationDate;
  final double progress;
  final VoidCallback? onTap;
  final bool isDark;

  const CourseListProgress({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.registrationDate,
    required this.progress,
    this.onTap,
    this.isDark = false,
  }) : super(key: key);

  Color _getProgressColor() {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Registered on $registrationDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}% completed',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.play_circle_fill,
            color: isDark ? Colors.indigo[300] : Colors.indigo,
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
