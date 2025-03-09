import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CourseListProgress extends StatelessWidget {
  final String title;
  final String? description;
  final String? thumbnail;
  final String? thumbnailUrl;
  final double progress;
  final double? rating;
  final int? reviews;
  final DateTime? registrationDate;
  final VoidCallback onTap;
  final ImageService? imageService;
  final bool isDark;
  final List<String>? tags;

  const CourseListProgress({
    Key? key,
    required this.title,
    this.description,
    this.thumbnail,
    this.thumbnailUrl,
    required this.progress,
    this.rating,
    this.reviews,
    this.registrationDate,
    required this.onTap,
    this.imageService,
    this.isDark = false,
    this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? AppColors.darkCardBackground : AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tags != null && tags!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: tags!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 4),
                          itemBuilder: (context, index) {
                            return TagChip(tag: tags![index]);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (rating != null && reviews != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating!.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${reviews!})',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    LinearPercentIndicator(
                      percent: progress.clamp(0.0, 1.0),
                      lineHeight: 8,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      progressColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 120,
        height: 120,
        child: imageService?.getCourseImage(
              course: CourseModel(
                id: thumbnailUrl?.hashCode.toString() ?? '',
                title: title,
                description: description ?? '',
                thumbnail: thumbnail ?? thumbnailUrl ?? '',
                price: 0,
              ),
              width: 120,
              height: 120,
            ) ??
            _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 32,
          color: isDark ? Colors.grey[700] : Colors.grey[400],
        ),
      ),
    );
  }
}
