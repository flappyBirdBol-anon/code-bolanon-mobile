import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'learner_wishlists_viewmodel.dart';

class LearnerWishlistsView extends StackedView<LearnerWishlistsViewModel> {
  const LearnerWishlistsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerWishlistsViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'My Wishlist',
        showNotificationButton: false,
        showSearchButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshCourses,
            tooltip: 'Refresh wishlist',
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isBusy) {
            return _buildLoadingState(isDark);
          }

          if (viewModel.hasError) {
            return _buildErrorState(viewModel, isDark);
          }

          if (viewModel.wishlistedCourses.isEmpty) {
            return _buildEmptyState(viewModel, isDark);
          }

          return _buildWishlistItems(context, viewModel, isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your wishlist...',
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(LearnerWishlistsViewModel viewModel, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: isDark ? Colors.red[300] : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading wishlist',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.modelError?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.refreshCourses(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LearnerWishlistsViewModel viewModel, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.pink.withOpacity(0.1)
                  : Colors.pink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: isDark ? Colors.pink[300] : Colors.pink,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Wishlist is Empty',
            style: GoogleFonts.figtree(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Save your favorite courses to your wishlist for easy access later. Explore our catalog to find courses that interest you!',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => viewModel.navigateToExploreCourses(),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => viewModel.navigateToMyCourses(),
            child: Text(
              'Back to My Courses',
              style: GoogleFonts.figtree(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(
      BuildContext context, LearnerWishlistsViewModel viewModel, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved for Later',
                  style: GoogleFonts.figtree(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Courses you\'re interested in',
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Wishlist Items with animations
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final course = viewModel.wishlistedCourses[index];
                final tags = viewModel.getCourseTags(course);
                final lessonCount = viewModel.getActualLessonCount(course);

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: Card(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () =>
                              viewModel.navigateToCourseDetails(course),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course Image
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
                                      child: viewModel.getCourseImageWidget(
                                        course: course,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // Dark overlay gradient
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
                                  if (course.level.isNotEmpty)
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          course.level,
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

                                  // Price badge
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: course.price <= 0
                                            ? Colors.green.withOpacity(0.8)
                                            : Colors.orange.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        course.price <= 0
                                            ? 'Free'
                                            : '\$${course.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.figtree(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Remove from wishlist button
                                  Positioned(
                                    bottom: 12,
                                    right: 12,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          final result = await viewModel
                                              .removeFromWishlist(course);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(result['message']),
                                                backgroundColor:
                                                    result['success']
                                                        ? Colors.green
                                                        : Colors.red,
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
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
                                      course.title,
                                      style: GoogleFonts.figtree(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    // Description
                                    Text(
                                      course.description,
                                      style: GoogleFonts.figtree(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // Rating if available
                                    if (course.rating > 0)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 18,
                                            color: Colors.amber[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            course.rating.toStringAsFixed(1),
                                            style: GoogleFonts.figtree(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          if (course.reviews > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${course.reviews})',
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

                                    // Tags if available
                                    if (tags.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 28,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              tags.length > 3 ? 3 : tags.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 6),
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF334155)
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                tags[index],
                                                style: GoogleFonts.figtree(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black87,
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
                    ),
                  ),
                );
              },
              childCount: viewModel.wishlistedCourses.length,
            ),
          ),
        ),

        // Footer padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  @override
  LearnerWishlistsViewModel viewModelBuilder(BuildContext context) =>
      LearnerWishlistsViewModel(
        courseService: locator<CourseService>(),
        wishlistService: locator<WishlistService>(),
        imageService: locator<ImageService>(),
      )..init();
}
