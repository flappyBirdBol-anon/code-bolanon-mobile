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
        const SizedBox(height: 2), // Reduced spacing
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        if (onToggleStatus != null)
          Transform.scale(
            scale: 0.7,
            child: Switch.adaptive(
              value: course.isActive,
              onChanged: (_) => onToggleStatus?.call(),
              activeColor: AppColors.primary,
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
