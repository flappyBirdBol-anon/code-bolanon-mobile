import 'package:code_bolanon/models/course.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

class CoursesListItem extends StatelessWidget {
  final Course course;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final dynamic viewModel;
  final bool showControls;
  final bool? showStatus; // Add this property

  const CoursesListItem({
    super.key,
    required this.course,
    this.onEdit,
    this.onToggleStatus,
    required this.viewModel,
    this.showControls = false,
    this.showStatus = false, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => viewModel.navigateToCourseDetails(context, course),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), // Reduced padding
              child: _buildCourseContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildCourseImage(),
        ),
        if (showStatus ?? true) // Only show if showStatus is true or null
          Positioned(
            top: 8,
            right: 8,
            child: _buildStatusBadge(),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: course.isActive
            ? Colors.green.withOpacity(0.9)
            : Colors.grey.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        course.isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCourseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2), // Reduced spacing
        SizedBox(
          height: 28, // Reduced height
          child: Text(
            course.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11, // Slightly smaller font
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4), // Reduced spacing
        _buildInfoRow(),
        const SizedBox(height: 14), // Reduced spacing
        _buildActionRow(),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${course.studentsEnrolled}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.star, size: 14, color: Colors.amber[400]),
        const SizedBox(width: 4),
        Text(
          '4.5', // Replace with actual rating
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          '\$${course.price}.00',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    if (!showControls) return const SizedBox.shrink();

    return Row(
      children: [
        if (onEdit != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const Spacer(),
        if (onToggleStatus != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleStatus,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: course.isActive
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      course.isActive ? Icons.toggle_on : Icons.toggle_off,
                      size: 18,
                      color: course.isActive ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.isActive ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            course.isActive ? AppColors.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCourseImage() {
    return viewModel.getCourseImageWidget(
      course: course,
      fit: BoxFit.cover,
      placeholder: Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
