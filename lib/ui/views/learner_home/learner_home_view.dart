import 'package:carousel_slider/carousel_slider.dart';
import 'package:code_bolanon/models/course_model.dart' as api_model;
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/utils/tech_stack_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_learner_coures_card.dart';
import 'package:code_bolanon/ui/common/widgets/custom_stack_chip.dart';
import 'package:code_bolanon/ui/common/widgets/empty_state_widget.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import 'learner_home_viewmodel.dart';

class LearnerHomeView extends StackedView<LearnerHomeViewModel> {
  const LearnerHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerHomeViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Custom text styles with Google Fonts
    final headingStyle = GoogleFonts.figtree(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final bodyStyle = GoogleFonts.figtree(
      fontSize: 14,
      color: AppColors.primary,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Colors.white,
          onRefresh: () async => viewModel.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildHeader(viewModel, theme),
                  const SizedBox(height: 24),
                  _buildQuickStats(viewModel, theme, headingStyle, bodyStyle),
                  const SizedBox(height: 24),
                  _buildPopularCoursesCarousel(
                      viewModel, theme, headingStyle, bodyStyle),
                  const SizedBox(height: 24),
                  _buildRecommendedCourses(
                      viewModel, theme, headingStyle, bodyStyle),
                  const SizedBox(height: 24),
                  _buildTopRatedCourses(
                      viewModel, theme, headingStyle, bodyStyle),
                  const SizedBox(height: 24),
                  _buildRecentRegisteredCourses(
                      viewModel, context, theme, headingStyle, bodyStyle),
                  const SizedBox(height: 24),
                  _buildUpcomingSessions(viewModel, theme, headingStyle),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LearnerHomeViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => viewModel.openProfile(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2.0,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: ClipOval(
                  child: viewModel.userImage.isEmpty
                      ? Icon(Icons.person,
                          size: 30, color: Colors.white.withOpacity(0.7))
                      : viewModel.getProfileImageWidget(
                          fit: BoxFit.cover,
                          placeholder: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.figtree(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.userFullName,
                  style: GoogleFonts.figtree(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          _headerIconButton(Icons.notifications_outlined,
              () => viewModel.showNotifications()),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildQuickStats(LearnerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Progress", style: headingStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                'In Progress',
                viewModel.isLoading
                    ? null
                    : viewModel.inProgressCourses.toString(),
                Icons.play_circle_outline,
                theme,
                bodyStyle,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                'Completed',
                viewModel.isLoading
                    ? null
                    : viewModel.completedCourses.toString(),
                Icons.check_circle_outline,
                theme,
                bodyStyle,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                'Enrolled',
                viewModel.isLoading
                    ? null
                    : viewModel.totalEnrolledCourses.toString(),
                Icons.school_outlined,
                theme,
                bodyStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? Colors.grey[700] : Colors.grey[300],
    );
  }

  Widget _buildStatItem(String title, String? value, IconData icon,
      ThemeData theme, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.primary : AppColors.primary;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: bodyStyle.copyWith(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          value == null
              ? Shimmer.fromColors(
                  period: const Duration(milliseconds: 2000),
                  baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[600]! : Colors.grey[100]!,
                  direction: ShimmerDirection.ltr,
                  enabled: true,
                  child: Container(
                    width: 50,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: bodyStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCourses(LearnerHomeViewModel viewModel,
      ThemeData theme, TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: headingStyle.copyWith(fontSize: 20),
        ),
        Text(
          'Based on your tech stack preferences',
          style: bodyStyle.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14),
        ),
        const SizedBox(height: 12),
        // Display user's tech stacks
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: viewModel.techStack.map((stack) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomStackChip(
                  label: stack,
                  selected: true,
                  isDark: isDark,
                  icon: Icons.code,
                  color: TechStackColors.getColorForTech(stack, theme),
                  textStyle: GoogleFonts.figtree(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: () {},
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildHorizontalCardsShimmer()
            : viewModel.recommendedCourses.isEmpty
                ? EmptyStateWidget(
                    animationPath: PngImages.recentAnim,
                    title: 'No Recommendations Yet',
                    description:
                        'Update your tech stack to get personalized recommendations',
                    buttonText: 'Update Tech Stack',
                    onActionPressed: () => viewModel.openProfile(),
                    animationSize: 180,
                    isDark: isDark,
                  )
                : SizedBox(
                    height: 245,
                    child: CarouselSlider.builder(
                      itemCount: viewModel.recommendedCourses.length,
                      itemBuilder: (context, index, realIndex) {
                        final course = viewModel.recommendedCourses[index];
                        final apiCourse = api_model.CourseModel(
                          id: (index + 1).toString(),
                          title: course.title,
                          price: course.price,
                          description: course.description,
                          thumbnail: course.imageUrl,
                          stacks: course.tags,
                          studentsEnrolled: course.enrolledStudents,
                          rating: course.rating,
                          reviews: course.reviews,
                          author: course.instructorName,
                          lessonCount: course.totalLessons,
                        );

                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 16),
                          child: CoursesListItem(
                            course: apiCourse,
                            onTap: () => viewModel.openCourse(course.title),
                            imageService: viewModel.imageService,
                            showStatus: false,
                            showControls: false,
                            tags: course.tags,
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 0.58,
                        enableInfiniteScroll:
                            viewModel.recommendedCourses.length > 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        pauseAutoPlayOnTouch: true,
                        enlargeCenterPage: true,
                        padEnds: true,
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildTopRatedCourses(LearnerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Rated',
          style: headingStyle.copyWith(fontSize: 20),
        ),
        Text(
          'Highest rated courses by learners',
          style: bodyStyle.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14),
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildHorizontalCardsShimmer()
            : viewModel.topRatedCourses.isEmpty
                ? EmptyStateWidget(
                    animationPath: PngImages.progessAnim,
                    title: 'No Top Rated Courses',
                    description: 'Check back later for top rated courses',
                    buttonText: 'Explore All Courses',
                    onActionPressed: () => viewModel.viewAllCourses(),
                    animationSize: 180,
                    isDark: isDark,
                  )
                : SizedBox(
                    height: 245,
                    child: CarouselSlider.builder(
                      itemCount: viewModel.topRatedCourses.length,
                      itemBuilder: (context, index, realIndex) {
                        final course = viewModel.topRatedCourses[index];
                        final apiCourse = api_model.CourseModel(
                          id: (index + 100).toString(),
                          title: course.title,
                          price: course.price,
                          description: course.description,
                          thumbnail: course.imageUrl,
                          stacks: course.tags,
                          studentsEnrolled: course.enrolledStudents,
                          rating: course.rating,
                          reviews: course.reviews,
                          author: course.instructorName,
                          lessonCount: course.totalLessons,
                        );

                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 16),
                          child: CoursesListItem(
                            course: apiCourse,
                            onTap: () => viewModel.openCourse(course.title),
                            imageService: viewModel.imageService,
                            showStatus: false,
                            showControls: false,
                            tags: course.tags,
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 0.57,
                        enableInfiniteScroll:
                            viewModel.topRatedCourses.length > 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 6),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        pauseAutoPlayOnTouch: true,
                        enlargeCenterPage: true,
                        padEnds: true,
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildPopularCoursesCarousel(LearnerHomeViewModel viewModel,
      ThemeData theme, TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Courses',
          style: headingStyle.copyWith(fontSize: 24),
        ),
        Text(
          'Most enrolled courses by learners',
          style: bodyStyle.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              fontSize: 14),
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildPopularCoursesShimmer()
            : viewModel.topRatedCourses.isEmpty
                ? EmptyStateWidget(
                    animationPath: PngImages.recentAnim,
                    title: 'No Popular Courses',
                    description: 'Explore courses to find popular options',
                    buttonText: 'Explore Courses',
                    onActionPressed: () => viewModel.viewAllCourses(),
                    animationSize: 180,
                    isDark: isDark,
                  )
                : SizedBox(
                    height: 220,
                    child: CarouselSlider.builder(
                      itemCount: viewModel.topRatedCourses.length,
                      itemBuilder: (context, index, realIndex) {
                        final course = viewModel.topRatedCourses[index];
                        return _buildPopularCourseCard(
                            course, viewModel, theme);
                      },
                      options: CarouselOptions(
                        height: 220,
                        viewportFraction: 0.85,
                        enlargeCenterPage: true,
                        enableInfiniteScroll:
                            viewModel.topRatedCourses.length > 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        pauseAutoPlayOnTouch: true,
                        padEnds: true,
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildPopularCoursesShimmer() {
    return SizedBox(
      height: 220,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 2000),
        direction: ShimmerDirection.ltr,
        child: CarouselSlider.builder(
          itemCount: 3,
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            padEnds: true,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCourseCard(
      CourseModel course, LearnerHomeViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Course Image with error handling using ImageService
            SizedBox(
              height: 220,
              width: 280,
              child: viewModel.imageService.loadImage(
                imageUrl: viewModel.imageService
                    .getCourseThumbnailFromPath(course.imageUrl),
                courseId: course.title.hashCode
                    .toString(), // Use hashcode of title as id substitute
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
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            // Content - Better gradient for readability
            Container(
              height: 220,
              width: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.75, 1.0],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title with better contrast
                    Text(
                      course.title,
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Course stats - more visible chips
                    Row(
                      children: [
                        // Rating chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.amber.withOpacity(0.7), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                course.enrolledStudents.toString(),
                                style: GoogleFonts.figtree(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Price with chip for visibility
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: course.price > 0
                                ? Colors.green.withOpacity(0.3)
                                : Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: course.price > 0
                                  ? Colors.green.withOpacity(0.7)
                                  : Colors.purple.withOpacity(0.7),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                course.price > 0
                                    ? Icons.attach_money
                                    : Icons.card_giftcard,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                course.price > 0
                                    ? '\$${course.price.toStringAsFixed(2)}'
                                    : 'FREE',
                                style: GoogleFonts.figtree(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Play overlay in the center
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => viewModel.openCourse(course.title),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRegisteredCourses(
      LearnerHomeViewModel viewModel,
      BuildContext context,
      ThemeData theme,
      TextStyle headingStyle,
      TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Learning',
              style: headingStyle.copyWith(fontSize: 24),
            ),
            TextButton(
              onPressed: () => viewModel.viewRegisteredCourses(),
              child: Text(
                "View All",
                style: GoogleFonts.figtree(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Your enrolled courses',
          style: GoogleFonts.figtree(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildProgressShimmer(isDark)
            : viewModel.registeredCourses.isEmpty
                ? _buildEmptyCard(
                    "No Enrolled Courses",
                    "Explore and join courses to track your progress here.",
                    Icons.school,
                    isDark,
                    cardColor,
                  )
                : SizedBox(
                    height: 280, // Keep increased height to avoid overflow
                    child: CarouselSlider.builder(
                      itemCount: viewModel.registeredCourses.length,
                      itemBuilder: (context, index, realIndex) {
                        final course = viewModel.registeredCourses[index];
                        // Calculate progress from the viewModel
                        final progress = viewModel.computeProgress(course);
                        // Get tags from the viewModel
                        final tags = viewModel.getCourseTags(course);
                        // Count lessons from the registration data
                        int actualLessonCount = 0;
                        if (course.registration?.progress != null) {
                          actualLessonCount =
                              course.registration!.progress!.totalLessons;
                        } else if (course.registration?.lessons != null) {
                          // Fallback to the lessons array length
                          actualLessonCount =
                              course.registration!.lessons!.length;
                        } else {
                          // Final fallback to default values
                          actualLessonCount =
                              course.lessonCount ?? course.lessons ?? 0;
                        }
                        // Only show reviews if they exist and are greater than zero
                        final hasReviews =
                            course.reviews > 0 && course.rating > 0;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(
                              child: Container(
                                width: 220, // Fixed width to match other cards
                                margin: const EdgeInsets.only(right: 16),
                                child: CustomLearnerCourseCard(
                                  title: course.title,
                                  description: course.description.length > 15
                                      ? "${course.description.substring(0, 15)}..."
                                      : course
                                          .description, // Shorter truncation to prevent overflow
                                  thumbnail: course.imageUrl,
                                  progress: progress,
                                  rating: course.rating,
                                  reviews: hasReviews ? course.reviews : null,
                                  tags: tags,
                                  onTap: () => viewModel.openCourse(course.id),
                                  imageService: viewModel.imageService,
                                  isDark: isDark,
                                  variant: CardVariant.progress,
                                  lessonCount: actualLessonCount,
                                  level: course.level,
                                  price: course.price,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 450,
                        viewportFraction: 0.6,
                        enableInfiniteScroll:
                            viewModel.registeredCourses.length > 1,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        pauseAutoPlayOnTouch: true,
                        enlargeCenterPage: true,
                        padEnds: true,
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildUpcomingSessions(
      LearnerHomeViewModel viewModel, ThemeData theme, TextStyle headingStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Debug print to check appointments
    debugPrint(
        "DEBUGGING APPOINTMENTS: Total in viewModel: ${viewModel.upcomingSessions.length}");
    for (var app in viewModel.upcomingSessions) {
      debugPrint(
          "Appointment ID: ${app.id}, Status: ${app.status}, Start: ${app.startAt}, End: ${app.endAt}");
    }

    // Directly use upcomingSessions from viewModel to show all upcoming sessions
    final upcomingAppointments =
        viewModel.upcomingSessions.where((appointment) {
      return appointment.status.toLowerCase() != 'completed' &&
          appointment.status.toLowerCase() != 'cancelled';
    }).toList();

    debugPrint("Filtered appointments count: ${upcomingAppointments.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: headingStyle.copyWith(fontSize: 20),
            ),
            TextButton(
              onPressed: () => viewModel.navigateToLearnerBookedAppointments(),
              child: Text(
                "View All",
                style: GoogleFonts.figtree(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildAppointmentShimmer(isDark)
            : upcomingAppointments.isEmpty
                ? _buildEmptyCard(
                    "No Upcoming Appointments",
                    "Book sessions with trainers to see them here.",
                    Icons.calendar_today,
                    isDark,
                    cardColor,
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: upcomingAppointments.length > 3
                        ? 3
                        : upcomingAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = upcomingAppointments[index];

                      // Format date properly using datetime formatter
                      final DateFormat dateFormat = DateFormat('E, MMM d');
                      final DateFormat timeFormat = DateFormat('h:mm a');

                      final String formattedDate =
                          dateFormat.format(appointment.startAt);
                      final String startTime =
                          timeFormat.format(appointment.startAt);
                      final String endTime =
                          timeFormat.format(appointment.endAt);

                      // Check if appointment is ongoing
                      final now = DateTime.now();
                      final isOngoing = now.isAfter(appointment.startAt) &&
                          now.isBefore(appointment.endAt);

                      // Check if appointment is today
                      final isToday = appointment.startAt.day ==
                              DateTime.now().day &&
                          appointment.startAt.month == DateTime.now().month &&
                          appointment.startAt.year == DateTime.now().year;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                          border: isOngoing
                              ? Border.all(color: Colors.green, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            // Main content section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Left icon container
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isOngoing
                                          ? Colors.green.withOpacity(0.15)
                                          : (isDark
                                              ? Colors.blue.withOpacity(0.15)
                                              : Colors.blue.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isOngoing
                                          ? Icons.video_camera_front_outlined
                                          : Icons.calendar_today_outlined,
                                      color: isOngoing
                                          ? Colors.green
                                          : (isDark
                                              ? Colors.white
                                              : Colors.blue[700]),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Content section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.blue.withOpacity(0.2)
                                                : Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            formattedDate,
                                            style: GoogleFonts.figtree(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.blue[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 15,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "$startTime - $endTime",
                                              style: GoogleFonts.figtree(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 15,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              appointment.trainer?.fullName ??
                                                  'Unknown Trainer',
                                              style: GoogleFonts.figtree(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.grey[800],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.blue[700],
                                      size: 16,
                                    ),
                                    onPressed: () => viewModel
                                        .openSession(appointment.id.toString()),
                                  ),
                                ],
                              ),
                            ),

                            // Show join button for ongoing or today's sessions
                            if (isOngoing || isToday) ...[
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark
                                    ? Colors.grey[800]!.withOpacity(0.3)
                                    : Colors.grey[200],
                              ),
                              InkWell(
                                onTap: () => viewModel
                                    .openSession(appointment.id.toString()),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 16,
                                        color: isDark
                                            ? Colors.green[300]
                                            : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isOngoing ? 'Join Now' : 'View Details',
                                        style: GoogleFonts.figtree(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.green[300]
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildAppointmentShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 2000),
      direction: ShimmerDirection.ltr,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCard(String title, String description, IconData icon,
      bool isDark, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              color: isDark ? Colors.white : Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              color: isDark ? Colors.white : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 2000),
      direction: ShimmerDirection.ltr,
      child: Container(
        height: 265,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHorizontalCardsShimmer() {
    return SizedBox(
      height: 220,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 2000),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  LearnerHomeViewModel viewModelBuilder(BuildContext context) =>
      LearnerHomeViewModel();

  @override
  void onViewModelReady(LearnerHomeViewModel viewModel) {
    // Initialize directly
    viewModel.init();
  }
}
