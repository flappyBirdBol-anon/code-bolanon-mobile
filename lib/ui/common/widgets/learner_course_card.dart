import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnerCourseCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final double progress;
  final double rating;
  final int? reviews;
  final int lessonCount;
  final String level;
  final String duration;
  final List<String> tags;
  final VoidCallback onTap;
  final ImageService imageService;

  const LearnerCourseCard({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.progress,
    required this.rating,
    this.reviews,
    required this.lessonCount,
    required this.level,
    required this.duration,
    required this.tags,
    required this.onTap,
    required this.imageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardWidth =
        MediaQuery.of(context).size.width - 32; // Full width minus padding

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white12,
                    Color.fromARGB(146, 164, 217, 255),
                    Color.fromARGB(53, 13, 72, 161),
                    Color.fromARGB(44, 13, 72, 161),
                    Color.fromARGB(12, 255, 255, 255),
                  ],
                ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image with Progress Indicator
              Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 140,
                      child: _buildThumbnailImage(),
                    ),
                  ),

                  // Dark overlay for better visibility of elements - using gradient like in CourseDetailsView
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Course Level Badge
                  if (level.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          level,
                          style: GoogleFonts.figtree(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // Lessons count badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$lessonCount ${lessonCount == 1 ? 'Lesson' : 'Lessons'}',
                            style: GoogleFonts.figtree(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Progress bar container at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),

                  // Progress Indicator (filled portion)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      height: 8,
                      width: cardWidth * progress.clamp(0.0, 1.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primary,
                            Color(0xFF5E72E4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Course Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.figtree(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Stats and Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Progress Text
                        Text(
                          '${(progress * 100).toInt()}% Complete',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),

                        // Rating - only show if there are reviews
                        if (rating > 0 && (reviews ?? 0) > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.figtree(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (reviews != null && reviews! > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '($reviews)',
                                  style: GoogleFonts.figtree(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),

                    // Tags if available
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: tags.length > 3 ? 3 : tags.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                tags[index],
                                style: GoogleFonts.figtree(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build thumbnail image with proper handling
  Widget _buildThumbnailImage() {
    // Handle local assets differently
    if (thumbnail.startsWith('assets/')) {
      return Image.asset(
        thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    // Use ImageService for remote images
    final imageUrl = imageService.getCourseThumbnailFromPath(thumbnail);

    return imageService.loadImage(
      imageUrl: imageUrl,
      courseId: id,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholder(),
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
    );
  }
}
