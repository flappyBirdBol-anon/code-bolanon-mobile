import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/models/registration_model.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesListItem extends StatelessWidget {
  final CourseModel course;
  final RegistrationModel? registration;
  final VoidCallback onTap;
  final ImageService imageService;
  final bool showControls;
  final bool? showStatus;
  final List<String>? tags;
  final VoidCallback? onEditTap;
  final VoidCallback? onToggleTap;
  final bool isRegistered;
  final bool isCarouselItem;

  const CoursesListItem({
    super.key,
    required this.course,
    required this.onTap,
    required this.imageService,
    this.registration,
    this.showControls = false,
    this.showStatus = false,
    this.tags,
    this.onEditTap,
    this.onToggleTap,
    this.isRegistered = false,
    this.isCarouselItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 280,
        maxHeight: isCarouselItem ? 300 : 400,
      ),
      child: Card(
        color: AppColors.cardBackground,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color.fromARGB(157, 238, 238, 238)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Colors.white,
                  Colors.white12,
                  Color.fromARGB(146, 164, 217, 255),
                  Color.fromARGB(53, 13, 72, 161),
                  Color.fromARGB(44, 13, 72, 161),
                  Color.fromARGB(12, 255, 255, 255),
                ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.56,
                        child: _buildCourseImage(),
                      ),
                      if (showControls) ...[
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildEditButton(context),
                        ),
                      ],
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
                    padding: EdgeInsets.all(isCarouselItem ? 3 : 4),
                    child: Container(
                      padding: EdgeInsets.all(isCarouselItem ? 3 : 4),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey[300]!, width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  course.title,
                                  maxLines: isCarouselItem ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.figtree(
                                    fontSize: isCarouselItem ? 13 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (course.price == 0.00)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.card_giftcard,
                                        size: 11,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'FREE',
                                        style: GoogleFonts.figtree(
                                          fontSize: 9,
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
                                    fontSize: isCarouselItem ? 11 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          _buildCourseDetails(context),
                          const SizedBox(height: 2),
                          if (isCarouselItem)
                            Text(
                              course.author != null && course.author!.isNotEmpty
                                  ? "By ${course.author}"
                                  : "By Instructor",
                              style: GoogleFonts.figtree(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
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
                          if (course.description.isNotEmpty &&
                              !isCarouselItem) ...[
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                course.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.figtree(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[700],
                                ),
                              ),
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
      ),
    );
  }

  Widget _buildTagList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tags!
              .take(3)
              .map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TagChip(
                      tag: tag,
                      onTap: () {},
                      isSmall: isCarouselItem,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCourseDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCarouselItem ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildDetailItem(
            icon: Icons.book,
            iconColor: Colors.blue[700]!.withOpacity(0.8),
            backgroundColor: Colors.blue[50]!,
            label: '${course.lessonCount ?? course.lessons}',
            isCompact: isCarouselItem,
          ),
          const SizedBox(width: 8),
          _buildDetailItem(
            icon: Icons.star,
            iconColor: Colors.amber[700]!.withOpacity(0.8),
            backgroundColor: Colors.amber[50]!.withOpacity(0.8),
            label: course.rating.toStringAsFixed(1),
            showRating: true,
            isCompact: isCarouselItem,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    bool showRating = false,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 4 : 8, vertical: isCompact ? 1 : 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: backgroundColor.withOpacity(0.5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 10 : 14, color: iconColor),
          SizedBox(width: isCompact ? 2 : 4),
          Text(
            label,
            style: GoogleFonts.figtree(
              fontSize: isCompact ? 9 : 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_document,
                size: 25,
                color: AppColors.primary,
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
