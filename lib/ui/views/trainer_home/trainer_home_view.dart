import 'package:carousel_slider/carousel_slider.dart';
import 'package:code_bolanon/models/course_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/utils/tech_stack_colors.dart';
import 'package:code_bolanon/ui/common/widgets/courses_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_appointment_list.dart';
import 'package:code_bolanon/ui/common/widgets/custom_card.dart';
import 'package:code_bolanon/ui/common/widgets/custom_list_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_stack_chip.dart';
import 'package:code_bolanon/ui/common/widgets/empty_state_widget.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/ui/views/trainer_home/trainer_home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

class TrainerHomeView extends StackedView<TrainerHomeViewModel> {
  const TrainerHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, TrainerHomeViewModel viewModel, Widget? child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Custom text styles with Google Fonts
    final headingStyle = GoogleFonts.figtree(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final subheadingStyle = GoogleFonts.figtree(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final bodyStyle = GoogleFonts.figtree(
      fontSize: 14,
      color: AppColors.primary,
    );

    final codeStyle = GoogleFonts.firaCode(
      fontSize: 13,
      fontWeight: FontWeight.w500,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildHeader(viewModel, theme),
                      const SizedBox(height: 24),
                      _buildQuickActions(
                          theme, headingStyle, bodyStyle, viewModel),
                      const SizedBox(height: 32),
                      _buildStats(
                          viewModel, theme, headingStyle, bodyStyle, context),
                      const SizedBox(height: 32),
                      Text("Your Courses", style: headingStyle),
                      const SizedBox(height: 16),
                      _buildFeatureCourses(viewModel, theme, bodyStyle),
                      const SizedBox(height: 32),
                      _buildStudentProgress(
                          theme, headingStyle, bodyStyle, viewModel),
                      const SizedBox(height: 32),
                      _buildCodingLanguages(
                          viewModel, theme, headingStyle, codeStyle),
                      const SizedBox(height: 32),
                      _buildUpcomingSessions(viewModel),
                      const SizedBox(height: 32),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TrainerHomeViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Changed header background to a gradient
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
          Container(
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
              // backgroundImage: AssetImage(viewModel.profileImageUrl),
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
                  viewModel.userName,
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
          // Help/Support icon
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => viewModel.openHelpSupport(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          // _headerIconButton(Icons.search, () => viewModel.searchContent()),
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

  Widget _buildQuickActions(ThemeData theme, TextStyle headingStyle,
      TextStyle bodyStyle, TrainerHomeViewModel viewModel) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: headingStyle),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                    "New Course",
                    Icons.add_box_outlined,
                    AppColors.primary,
                    theme,
                    bodyStyle,
                    () => viewModel.createNewCourse()),
                _buildQuickActionButton(
                    "Analytics",
                    Icons.analytics_outlined,
                    AppColors.primary,
                    theme,
                    bodyStyle,
                    () => viewModel.openAnalytics()),
                _buildQuickActionButton(
                    "Appointments",
                    Icons.event_note_outlined,
                    AppColors.primary,
                    theme,
                    bodyStyle,
                    () => viewModel.openAppointment()),
                _buildQuickActionButton(
                    "Settings",
                    Icons.settings_outlined,
                    AppColors.primary,
                    theme,
                    bodyStyle,
                    () => viewModel.openSettings()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color,
      ThemeData theme, TextStyle textStyle, VoidCallback onTap) {
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.figtree(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(TrainerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle bodyStyle, BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Format the selected date to display
    final String displayDate = viewModel.selectedDate != null
        ? DateFormat('MMMM yyyy').format(viewModel.selectedDate!)
        : "This Month";

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Performance", style: headingStyle.copyWith(fontSize: 16)),
              InkWell(
                onTap: () => _showMonthYearPicker(context, viewModel, theme),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        displayDate,
                        style: bodyStyle.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                'Learners',
                viewModel.isLoading
                    ? null
                    : viewModel.getTotalLearnersEnrolled().toString(),
                Icons.people_outline,
                theme,
                bodyStyle,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                'Courses',
                viewModel.isLoading ? null : viewModel.totalCourses.toString(),
                Icons.code,
                theme,
                bodyStyle,
              ),
              _buildStatDivider(isDark),
              _buildStatItem(
                'Revenue',
                viewModel.isLoading ? null : 'P${viewModel.totalRevenue}',
                Icons.attach_money,
                theme,
                bodyStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Month/Year picker implementation
  void _showMonthYearPicker(
      BuildContext context, TrainerHomeViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final currentDate = viewModel.selectedDate ?? DateTime.now();
    final currentYear = currentDate.year;
    final currentMonth = currentDate.month;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int selectedYear = currentYear;

            // Get month names
            final monthNames = List.generate(12, (index) {
              return DateFormat('MMMM').format(DateTime(2022, index + 1));
            });

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Month & Year',
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Year selector with navigation
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_left,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            onPressed: () {
                              setState(() {
                                selectedYear--;
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              selectedYear.toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_right,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            onPressed: () {
                              setState(() {
                                selectedYear++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Month grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthIndex = index + 1;
                        final isSelected = monthIndex == currentMonth &&
                            selectedYear == currentYear;

                        return InkWell(
                          onTap: () {
                            viewModel.updateSelectedDate(
                                DateTime(selectedYear, monthIndex));
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              monthNames[index].substring(0, 3),
                              style: GoogleFonts.figtree(
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Set to current month/year
                          viewModel.updateSelectedDate(DateTime.now());
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : theme.primaryColor.withOpacity(0.1),
                          foregroundColor:
                              isDark ? Colors.white : theme.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reset to Current Month',
                          style: GoogleFonts.figtree(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _buildStudentProgress(ThemeData theme, TextStyle headingStyle,
      TextStyle bodyStyle, TrainerHomeViewModel viewModel) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final accentColor = AppColors.primary;

    // Filter out duplicate progress entries
    final uniqueProgressData = <CourseProgressData>[];
    for (final pd in viewModel.learnerProgressData) {
      if (!uniqueProgressData.any((e) => e.courseId == pd.courseId)) {
        uniqueProgressData.add(pd);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Learners Progress", style: headingStyle),
            TextButton.icon(
              onPressed: () => viewModel.viewAllCourses(),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: Text(
                "View All",
                style: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: viewModel.isLoading
              ? _buildProgressSkeleton()
              : viewModel.hasNoProgress
                  ? EmptyStateWidget(
                      animationPath: PngImages.progessAnim,
                      title: 'No Progress Data Yet',
                      description:
                          "Start creating courses to see learner progress here",
                      buttonText: 'Create a Course',
                      onActionPressed: () => viewModel.createNewCourse(),
                      isDark: isDark,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            ...uniqueProgressData
                                .take(3) // Show top 3 courses
                                .map((progressData) {
                              // Find the actual course for thumbnail
                              final course = viewModel.courseList.firstWhere(
                                (course) => course.id == progressData.courseId,
                                orElse: () => CourseModel(
                                  id: progressData.courseId,
                                  title: progressData.courseTitle,
                                  description: '',
                                  thumbnail: '',
                                  price: 0,
                                  rating: 0,
                                  lessons: 0,
                                  studentsEnrolled: 0,
                                  level: '',
                                  stacks: [],
                                ),
                              );
                              return _buildEnhancedProgressItem(
                                progressData,
                                course,
                                theme,
                                bodyStyle,
                                viewModel,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProgressItem(
      CourseProgressData progressData,
      CourseModel course,
      ThemeData theme,
      TextStyle bodyStyle,
      TrainerHomeViewModel viewModel) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[800];
    final accentColor = AppColors.primary;

    // Use only primary color for progress indicators
    final progressColor = AppColors.primary;

    return InkWell(
      onTap: () {
        viewModel.navigateToCourseDetails(course);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Course thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: course.thumbnail.isNotEmpty
                    ? _buildCourseImage(viewModel, course)
                    : Container(
                        color: progressColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            color: progressColor,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Course details and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          progressData.courseTitle,
                          style: GoogleFonts.figtree(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: progressColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${(progressData.progressPercentage * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.figtree(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: progressColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Learners enrolled indicator
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentsEnrolled} learners enrolled',
                        style: GoogleFonts.figtree(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Background container
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        // Progress indicator with animated fill
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0, end: progressData.progressPercentage),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Container(
                              height: 8,
                              width: MediaQuery.of(context).size.width * value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    progressColor.withOpacity(0.7),
                                    progressColor,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: progressColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${progressData.completedLessonsCount} of ${progressData.totalLessonsCount} completed",
                            style: GoogleFonts.figtree(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage(TrainerHomeViewModel viewModel, CourseModel course) {
    return viewModel.getCourseImageWidget(
      course: course,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      placeholder: Container(
        width: 70,
        height: 70,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: Container(
        width: 70,
        height: 70,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSkeleton() {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.ltr,
      enabled: true,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodingLanguages(TrainerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle codeStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your Stack", style: headingStyle),
            TextButton.icon(
              onPressed: () => viewModel.addToStack(),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: Text("Add", style: codeStyle.copyWith(fontSize: 12)),
              style: TextButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        viewModel.isLoading
            ? _buildTopicsSkeleton()
            : viewModel.topics.isEmpty
                ? EmptyStateWidget(
                    animationPath: 'assets/lottie/coding_animation.json',
                    title: 'Add Your Tech Stack',
                    description: 'Add technologies that you specialize in',
                    buttonText: 'Add Technologies',
                    onActionPressed: () => viewModel.addToStack(),
                    animationSize: 150,
                    isDark: isDark,
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.topics.map((topic) {
                      return _buildLanguageChip(topic, theme, codeStyle);
                    }).toList(),
                  ),
      ],
    );
  }

  Widget _buildLanguageChip(
      String language, ThemeData theme, TextStyle codeStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final color = TechStackColors.getColorForTech(language, theme);

    return CustomStackChip(
      label: language,
      selected: true,
      isDark: isDark,
      icon: Icons.code,
      color: color,
      textStyle: codeStyle,
      onTap: () {},
    );
  }

  Widget _buildTopicsSkeleton() {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.ltr,
      enabled: true,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(8, (index) {
          return Container(
            width: 90 + (index % 3) * 30,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeatureCourses(
      TrainerHomeViewModel viewModel, ThemeData theme, TextStyle bodyStyle) {
    if (viewModel.isLoading) {
      return CustomCard(
        text: '',
        onPressed: () {},
        isHorizontalCard: true,
        isLoading: true,
        itemCount: 3,
      );
    }

    final isDark = theme.brightness == Brightness.dark;

    // Show empty state if no courses
    if (viewModel.hasNoCourses) {
      return EmptyStateWidget(
        animationPath: 'assets/lottie/trainer_animation.json',
        title: 'No Courses Yet',
        description: 'Create your first course to start teaching',
        buttonText: 'Create Course',
        onActionPressed: () => viewModel.createNewCourse(),
        isDark: isDark,
      );
    }

    // Wrap CarouselSlider with SizedBox to ensure stable dimensions
    return SizedBox(
      height: 250, // Fixed height to prevent layout jumps
      child: CarouselSlider.builder(
        itemCount: viewModel.courseList.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final course = viewModel.courseList[index];
          return CoursesListItem(
            course: course,
            onTap: () => viewModel.navigateToCourseDetails(course),
            imageService: viewModel.imageService,
            showStatus: true,
            showControls: false,
            tags: viewModel.getCourseTags(course),
          );
        },
        options: CarouselOptions(
          height: 350,
          viewportFraction: 0.52,

          // Disable autoplay initially - will help prevent rendering issues
          autoPlay: true,
          enableInfiniteScroll: viewModel.courseList.length > 1,
          padEnds: true,
          // Add initialPage to ensure consistent starting position
          initialPage: 0,
          // Add pauseAutoPlayOnTouch to prevent scroll conflicts
          pauseAutoPlayOnTouch: true,
          // Add pauseAutoPlayOnManualNavigate to prevent scroll conflicts
          pauseAutoPlayInFiniteScroll: true,
          // Increased page view port to ensure better rendering
          enlargeCenterPage: true,
        ),
      ),
    );
  }

  Widget _buildActivitySkeleton() {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.ltr,
      enabled: true,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingSessions(TrainerHomeViewModel viewModel) {
    // Get context safely and determine if we're in dark mode
    final navigatorKey = viewModel.navigationService.navigatorKey;
    final context = navigatorKey?.currentContext;
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Upcoming Appointments",
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => viewModel.openAppointment(),
              icon: const Icon(Icons.event, size: 16, color: AppColors.primary),
              label: Text(
                "Schedule",
                style: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: viewModel.isLoading
              ? _buildAppointmentSkeletons(2)
              : viewModel.hasNoSessions
                  ? EmptyStateWidget(
                      animationPath: PngImages.sessionAnim,
                      title: 'No Upcoming Appointments',
                      description:
                          'Schedule your first appointment with learners',
                      buttonText: 'Schedule appointments',
                      onActionPressed: () => viewModel.openAppointment(),
                      animationSize: 180,
                      isDark: isDark,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                        children: [
                          ...viewModel.upcomingAppointments.map((appointment) {
                            // Format the dates for display
                            final startDate = appointment.startAt;
                            final endDate = appointment.endAt;

                            // Format for "Today/Tomorrow/Monday at 3:00 PM" style
                            final now = DateTime.now();
                            final today =
                                DateTime(now.year, now.month, now.day);
                            final tomorrow = today.add(const Duration(days: 1));
                            final startDay = DateTime(
                                startDate.year, startDate.month, startDate.day);

                            String dayString;
                            if (startDay.isAtSameMomentAs(today)) {
                              dayString = "Today";
                            } else if (startDay.isAtSameMomentAs(tomorrow)) {
                              dayString = "Tomorrow";
                            } else {
                              dayString = DateFormat('EEEE, MMM d')
                                  .format(startDate); // e.g. "Monday, Jan 15"
                            }

                            final startTimeString = DateFormat('h:mm a')
                                .format(startDate); // e.g. "3:00 PM"
                            final endTimeString = DateFormat('h:mm a')
                                .format(endDate); // e.g. "4:00 PM"

                            // Calculate time remaining
                            final Duration timeUntil =
                                startDate.difference(now);
                            final bool isUpcoming = timeUntil.inMinutes > 0;
                            String timeRemaining = '';
                            Color statusColor = const Color(
                                0xFF3ED598); // Default green for upcoming
                            IconData statusIcon = Icons.access_time;

                            if (isUpcoming) {
                              if (timeUntil.inDays > 0) {
                                timeRemaining =
                                    '${timeUntil.inDays}d remaining';
                                statusIcon = Icons.calendar_today;
                              } else if (timeUntil.inHours > 0) {
                                timeRemaining =
                                    '${timeUntil.inHours}h remaining';
                                statusIcon = Icons.hourglass_top;
                              } else {
                                timeRemaining =
                                    '${timeUntil.inMinutes}m remaining';
                                statusColor =
                                    const Color(0xFFFE7F4D); // Orange for soon
                                statusIcon = Icons.timer;
                              }
                            } else {
                              // Check if in progress
                              if (endDate.isAfter(now)) {
                                timeRemaining = 'In progress';
                                statusColor = AppColors
                                    .primary; // App primary for in progress
                                statusIcon = Icons.play_circle_outline;
                              } else {
                                timeRemaining = 'Completed';
                                statusColor = Colors.grey;
                                statusIcon = Icons.check_circle_outline;
                              }
                            }

                            return _buildEnhancedAppointmentItem(
                              context:
                                  appointment.contextDetails ?? 'Appointment',
                              dayAndStart: '$dayString at $startTimeString',
                              endTime: endTimeString,
                              timeRemaining: timeRemaining,
                              statusColor: statusColor,
                              statusIcon: statusIcon,
                              theme: Theme.of(context!),
                              onTap: () => viewModel
                                  .openSession(appointment.id.toString()),
                              appointmentType: _getAppointmentType(
                                  appointment.contextDetails ?? ''),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  String _getAppointmentType(String contextDetails) {
    final normalizedContext = contextDetails.toLowerCase();
    if (normalizedContext.contains('debug') ||
        normalizedContext.contains('fixing')) {
      return 'debugging';
    } else if (normalizedContext.contains('review') ||
        normalizedContext.contains('feedback')) {
      return 'review';
    } else if (normalizedContext.contains('guidance') ||
        normalizedContext.contains('help')) {
      return 'guidance';
    } else if (normalizedContext.contains('interview') ||
        normalizedContext.contains('career')) {
      return 'interview';
    } else {
      return 'general';
    }
  }

  Widget _buildEnhancedAppointmentItem({
    required String context,
    required String dayAndStart,
    required String endTime,
    required String timeRemaining,
    required Color statusColor,
    required IconData statusIcon,
    required ThemeData theme,
    required VoidCallback onTap,
    required String appointmentType,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[800];

    // Define appointment type icons
    final Map<String, IconData> typeIcons = {
      'debugging': Icons.bug_report,
      'review': Icons.rate_review,
      'guidance': Icons.help_outline,
      'interview': Icons.work_outline,
      'general': Icons.event_note,
    };

    // Define appointment type colors
    final Map<String, Color> typeColors = {
      'debugging': const Color(0xFFE74C3C), // Red for debugging
      'review': const Color(0xFFF39C12), // Yellow for review
      'guidance': AppColors.primary, // App primary for guidance
      'interview': const Color(0xFF9B59B6), // Purple for interview
      'general': const Color(0xFF3498DB), // Blue for general
    };

    final typeIcon = typeIcons[appointmentType] ?? Icons.event_note;
    final typeColor = typeColors[appointmentType] ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time indicator with appointment type
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor.withOpacity(0.7),
                    typeColor,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                typeIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Appointment details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context,
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dayAndStart,
                        style: GoogleFonts.figtree(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        " - $endTime",
                        style: GoogleFonts.figtree(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Appointment type indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: typeColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      appointmentType.capitalize(),
                      style: GoogleFonts.figtree(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeRemaining,
                    style: GoogleFonts.figtree(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentSkeletons(int count) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  @override
  TrainerHomeViewModel viewModelBuilder(BuildContext context) =>
      TrainerHomeViewModel();

  @override
  void onViewModelReady(TrainerHomeViewModel viewModel) => viewModel.init();
}
