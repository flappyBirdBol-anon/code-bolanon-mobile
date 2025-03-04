import 'package:carousel_slider/carousel_slider.dart';
import 'package:code_bolanon/ui/common/widgets/custom_card.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/ui/views/trainer_home/trainer_home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

class TrainerHomeView extends StackedView<TrainerHomeViewModel> {
  const TrainerHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, TrainerHomeViewModel viewModel, Widget? child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Custom text styles with Google Fonts
    final headingStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final subheadingStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    final bodyStyle = GoogleFonts.inter(
      fontSize: 14,
    );

    final codeStyle = GoogleFonts.firaCode(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.grey,
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
                      _buildCodeChallenges(
                          theme, headingStyle, bodyStyle, codeStyle, viewModel),
                      const SizedBox(height: 32),
                      _buildUpcomingSessions(
                          viewModel, theme, headingStyle, bodyStyle),
                      const SizedBox(height: 32),
                      _buildRecentActivity(
                          viewModel, theme, headingStyle, bodyStyle),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => viewModel.createNewCourse(),
      //   elevation: 8,
      //   backgroundColor: theme.primaryColor,
      //   tooltip: 'Create new course',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildHeader(TrainerHomeViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Changed header background to a gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
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
              backgroundImage: AssetImage(viewModel.profileImageUrl),
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.userName,
                  style: GoogleFonts.inter(
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
                    Colors.blue,
                    theme,
                    bodyStyle,
                    () => viewModel.createNewCourse()),
                _buildQuickActionButton(
                    "Review",
                    Icons.rate_review_outlined,
                    Colors.amber,
                    theme,
                    bodyStyle,
                    () => viewModel.reviewContent()),
                _buildQuickActionButton(
                    "Analytics",
                    Icons.analytics_outlined,
                    Colors.green,
                    theme,
                    bodyStyle,
                    () => viewModel.openAnalytics()),
                _buildQuickActionButton(
                    "Schedule",
                    Icons.event_note_outlined,
                    Colors.purple,
                    theme,
                    bodyStyle,
                    () => viewModel.openSchedule()),
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
              style: textStyle.copyWith(
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
                'Students',
                viewModel.isLoading
                    ? null
                    : viewModel.activeStudents.toString(),
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
                viewModel.isLoading ? null : '\$${viewModel.totalRevenue}',
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
                          style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
                          style: GoogleFonts.inter(
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
    final color = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);

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
                  baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[600]! : Colors.grey[100]!,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Student Progress", style: headingStyle),
        const SizedBox(height: 16),
        Container(
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
          child: viewModel.isLoading
              ? _buildProgressSkeleton()
              : Column(
                  children: [
                    _buildProgressItem(
                      "JavaScript Fundamentals",
                      0.78,
                      "78% of students completed",
                      Colors.blue,
                      theme,
                      bodyStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressItem(
                      "React Components",
                      0.45,
                      "45% of students completed",
                      Colors.purple,
                      theme,
                      bodyStyle,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressItem(
                      "API Integration",
                      0.32,
                      "32% of students completed",
                      Colors.green,
                      theme,
                      bodyStyle,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => viewModel.viewAllCourses(),
                        child: Text(
                          "View All Courses",
                          style: bodyStyle.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildProgressSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, String subtitle,
      Color color, ThemeData theme, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: bodyStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 6,
          percent: progress,
          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
          progressColor: color,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: bodyStyle.copyWith(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
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
              icon: const Icon(Icons.add, size: 16),
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

    // Language-specific colors
    final Map<String, Color> languageColors = {
      'JavaScript': Colors.yellow[700]!,
      'Python': Colors.blue[700]!,
      'Java': Colors.orange[800]!,
      'Ruby': Colors.red[700]!,
      'C#': Colors.purple[700]!,
      'PHP': Colors.indigo[600]!,
      'Swift': Colors.orange[600]!,
      'Kotlin': Colors.purple[600]!,
      'Go': Colors.cyan[700]!,
      'TypeScript': Colors.blue[600]!,
      'C++': Colors.blue[800]!,
      'Rust': Colors.deepOrange[800]!,
      'Development': Colors.teal[700]!,
      'Design': Colors.pink[600]!,
      'Tech': Colors.indigo[500]!,
      'Marketing': Colors.green[700]!,
      'Business': Colors.amber[800]!,
      'Sports': Colors.lightBlue[700]!,
      'IT Software': Colors.deepPurple[600]!,
    };

    final color = languageColors[language] ?? theme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.5 : 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: isDark ? color.withOpacity(0.9) : color,
              ),
              const SizedBox(width: 8),
              Text(
                language,
                style: codeStyle.copyWith(
                  color: isDark ? color.withOpacity(0.9) : color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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

  Widget _buildCodeChallenges(
      ThemeData theme,
      TextStyle headingStyle,
      TextStyle bodyStyle,
      TextStyle codeStyle,
      TrainerHomeViewModel viewModel) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Code Challenges", style: headingStyle),
            TextButton(
              onPressed: () => viewModel.viewAllChallenges(),
              child: Text(
                "View All",
                style: bodyStyle.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
          child: viewModel.isLoading
              ? _buildChallengesSkeleton()
              : Column(
                  children: [
                    _buildChallengeItem(
                      "Algorithm Challenge",
                      "Array Manipulation",
                      "Intermediate",
                      Colors.orange,
                      isDark,
                      bodyStyle,
                      codeStyle,
                      () => viewModel.openChallenge("Algorithm Challenge"),
                    ),
                    const Divider(height: 24),
                    _buildChallengeItem(
                      "Project Challenge",
                      "Build a REST API",
                      "Advanced",
                      Colors.red,
                      isDark,
                      bodyStyle,
                      codeStyle,
                      () => viewModel.openChallenge("Project Challenge"),
                    ),
                    const Divider(height: 24),
                    _buildChallengeItem(
                      "Bug Fix Challenge",
                      "Debug React Components",
                      "Beginner",
                      Colors.green,
                      isDark,
                      bodyStyle,
                      codeStyle,
                      () => viewModel.openChallenge("Bug Fix Challenge"),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildChallengesSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              if (index < 2) const Divider(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeItem(
      String title,
      String subtitle,
      String level,
      Color levelColor,
      bool isDark,
      TextStyle bodyStyle,
      TextStyle codeStyle,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.code,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: codeStyle.copyWith(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                level,
                style: bodyStyle.copyWith(
                  fontSize: 12,
                  color: levelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.6,
        enableInfiniteScroll: false,
        padEnds: false,
      ),
      items: viewModel.featureCourses.map((course) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => viewModel.openCourse(course.id),
              child: CustomCard(
                text: course.title,
                onPressed: () => viewModel.openCourse(course.id),
                isHorizontalCard: true,
                isLoading: false,
                backgroundColor: cardColor,
                height: 200,
                width: 260,
                imageUrl: course.imageUrl,
                lessons: course.lessons,
                rating: course.rating,
                reviews: course.reviews,
                price: '\$${course.price}',
                instructorName: 'Sample',
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(TrainerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Activity", style: headingStyle),
        const SizedBox(height: 16),
        Container(
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
          child: viewModel.isLoading
              ? _buildActivitySkeleton()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.recentActivities.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    indent: 60,
                  ),
                  itemBuilder: (context, index) {
                    final activity = viewModel.recentActivities[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity.icon,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        activity.title,
                        style: bodyStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        activity.timestamp,
                        style: bodyStyle.copyWith(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          onPressed: () => viewModel.openActivity(activity.id),
                        ),
                      ),
                      onTap: () => viewModel.openActivity(activity.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivitySkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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

  Widget _buildUpcomingSessions(TrainerHomeViewModel viewModel, ThemeData theme,
      TextStyle headingStyle, TextStyle bodyStyle) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upcoming Sessions", style: headingStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(isDark ? 0.3 : 0.2),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.video_camera_front_outlined,
                      color: isDark ? Colors.white : Colors.indigo[700],
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advanced JavaScript Workshop',
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.white : Colors.indigo[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Today at 2:00 PM • 90 minutes',
                          style: GoogleFonts.inter(
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.indigo[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildAttendeeIndicator(),
                  const SizedBox(width: 8),
                  Text(
                    '24 students enrolled',
                    style: bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.8)
                          : Colors.indigo[700],
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => viewModel.startSession(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white.withOpacity(0.2) : Colors.white,
                      foregroundColor:
                          isDark ? Colors.white : Colors.indigo[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Start Session',
                      style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => viewModel.openReviewSession(),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_note_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code Review Session',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tomorrow at 10:00 AM',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeIndicator() {
    return SizedBox(
      width: 70,
      height: 28, // Fixed height to avoid layout issues
      child: Stack(
        children: [
          for (int i = 0; i < 3; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: AssetImage([
                      PngImages.image1,
                      PngImages.image2,
                      PngImages.image3
                    ][i]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 3 * 18.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.indigo[400],
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  '+21',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  TrainerHomeViewModel viewModelBuilder(BuildContext context) =>
      TrainerHomeViewModel();
}
