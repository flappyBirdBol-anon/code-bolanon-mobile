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
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 320,
        maxHeight: 400,
      ),
      child: Card(
        color: AppColors.cardBackground,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color.fromARGB(157, 238, 238, 238)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                // height: 160, // Fixed height for image container
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: _buildCourseImage(),
                    ),
                    if (showStatus ?? false)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStatusBadge(),
                      ),
                    if (tags != null && tags!.isNotEmpty)
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: _buildTagList(),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.figtree(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (course.price == 0.00)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      size: 14,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'FREE',
                                      style: GoogleFonts.figtree(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Text(
                                '\$${course.price.toStringAsFixed(2)}',
                                style: GoogleFonts.figtree(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                course.author ?? "Author",
                                style: GoogleFonts.figtree(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (course.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.figtree(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        _buildCourseDetails(context),
                        if (showControls) ...[
                          const SizedBox(height: 8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tags!
            .take(2) // Limit to 2 tags to prevent overflow
            .map((tag) => TagChip(
                  tag: tag,
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCourseDetails(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.book, size: 16, color: Colors.blue[700]),
        const SizedBox(width: 4),
        Text(
          '${course.lessonCount} lessons',
          style: GoogleFonts.figtree(fontSize: 12),
        ),
        const SizedBox(width: 40),
        Icon(Icons.star, size: 16, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Text(
          '${course.rating}',
          style: GoogleFonts.figtree(fontSize: 12),
        ),
      ],
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
                  fontSize: 10,
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
                isActive ? 'Deactivate' : 'Activate',
                style: GoogleFonts.figtree(
                  color: isActive ? Colors.red : Colors.green,
                  fontSize: 10,
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
