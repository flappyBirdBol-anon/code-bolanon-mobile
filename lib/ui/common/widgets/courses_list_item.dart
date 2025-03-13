import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesListItem extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final ImageService imageService;
  final bool showControls;
  final bool? showStatus;
  final List<String>? tags;
  final VoidCallback? onEditTap;
  final VoidCallback? onToggleTap;
  final bool isRegistered;

  const CoursesListItem({
    super.key,
    required this.course,
    required this.onTap,
    required this.imageService,
    this.showControls = false,
    this.showStatus = false,
    this.tags,
    this.onEditTap,
    this.onToggleTap,
    this.isRegistered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 8,
                      child: _buildCourseImage(),
                    ),
                    if (showStatus ?? false)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStatusBadge(),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (course.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.figtree(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              )),
                        ],
                        if (tags != null && tags!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tags!
                                .map((tag) => TagChip(
                                      tag: tag,
                                      onTap: () {},
                                    ))
                                .toList(),
                          ),
                        ],
                        const Spacer(),
                        if (showControls) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildEditButton(context),
                              const SizedBox(width: 8),
                              _buildToggleButton(context),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRegistered)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Enrolled',
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isRegistered)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.5),
                      Colors.green.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseImage() {
    return imageService.loadImage(
      imageUrl: imageService.getCourseThumbnailFromPath(course.thumbnail),
      courseId: course.id,
      fit: BoxFit.cover,
      placeholder: Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: Container(
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: course.isActive
            ? Colors.green.withOpacity(0.9)
            : Colors.grey.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        course.isActive ? 'Active' : 'Inactive',
        style: GoogleFonts.figtree(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEditTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Edit',
                style: GoogleFonts.figtree(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context) {
    final isActive = course.isActive;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isActive ? Colors.red : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 16,
                color: isActive ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.figtree(
                  color: isActive ? Colors.red : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
