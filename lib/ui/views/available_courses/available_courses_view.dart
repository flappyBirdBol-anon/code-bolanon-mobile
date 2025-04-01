import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'available_courses_viewmodel.dart';

class AvailableCoursesView extends StackedView<AvailableCoursesViewModel> {
  const AvailableCoursesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AvailableCoursesViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width < 600
        ? 2
        : size.width < 900
            ? 3
            : 4;
    final aspectRatio = size.width < 600 ? 0.73 : 0.75;
    final padding = size.width < 600 ? 10.0 : 24.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Available Courses',
        showSearchButton: true,
        showNotificationButton: false,
        onSearchTap: (query) => viewModel.onSearchChanged(query),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppColors.primary, Colors.blue.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Courses',
                            style: GoogleFonts.figtree(
                              fontSize: size.width < 600 ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover and enroll in exciting courses',
                            style: GoogleFonts.figtree(
                              fontSize: size.width < 600 ? 14 : 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Courses Grid Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                    left: padding, top: 16.0, bottom: 8.0, right: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Courses',
                      style: GoogleFonts.figtree(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blueGrey.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: isDark ? Colors.amber : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Interactive',
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.amber : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Courses Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = viewModel.courses[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: crossAxisCount,
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: CoursesListItem(
                            course: course,
                            onTap: () =>
                                viewModel.navigateToCourseDetails(course),
                            imageService: viewModel.imageService,
                            tags: viewModel.getCourseTags(course),
                            isRegistered:
                                viewModel.isCourseRegistered(course.id),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: viewModel.courses.length,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: viewModel.courses.isEmpty
          ? null
          : _buildAnimatedFAB(context, viewModel),
    );
  }

  Widget _buildAnimatedFAB(
      BuildContext context, AvailableCoursesViewModel viewModel) {
    return Hero(
      tag: 'fab_course',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => viewModel.navigateToMyCourses(),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.book_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  AvailableCoursesViewModel viewModelBuilder(context) =>
      AvailableCoursesViewModel(
        courseService: locator<CourseService>(),
        imageService: locator<ImageService>(),
      );
}
