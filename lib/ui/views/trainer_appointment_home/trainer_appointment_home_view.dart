import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_appointment_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'trainer_appointment_home_viewmodel.dart';

class TrainerAppointmentHomeView
    extends StackedView<TrainerAppointmentHomeViewModel> {
  const TrainerAppointmentHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerAppointmentHomeViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'Appointments',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF4C3575)),
            onPressed: () {
              viewModel.navigateToSchedules();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.fetchAppointments(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards Section
                _buildStatsSection(context, viewModel, isDark),

                const SizedBox(height: 15),

                // Today's Schedule Section
                _buildTodayScheduleSection(context, viewModel, isDark),

                const SizedBox(height: 15),

                // Upcoming Appointments Section
                _buildSectionHeader(
                  'Upcoming Appointments',
                  viewModel.isLoading,
                  isDark,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      size: 20,
                    ),
                    onPressed: () {
                      // Filter functionality
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: viewModel.isLoading &&
                          viewModel.upcomingAppointments.isEmpty
                      ? _buildSkeletonLoaders()
                      : viewModel.upcomingAppointments.isEmpty
                          ? _buildEmptyState(
                              'No upcoming appointments',
                              'Your upcoming lessons will appear here',
                              Icons.event_note_outlined,
                              isDark,
                            )
                          : Column(
                              children: _buildUpcomingAppointmentsList(
                                viewModel.upcomingAppointments,
                                viewModel,
                                isDark,
                              ),
                            ),
                ),

                const SizedBox(height: 20),

                // Completed Appointments Section
                _buildSectionHeader(
                  'Completed Appointments',
                  viewModel.isLoading &&
                      viewModel.completedAppointments.isEmpty,
                  isDark,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: viewModel.isLoading &&
                          viewModel.completedAppointments.isEmpty
                      ? _buildSkeletonLoaders()
                      : viewModel.completedAppointments.isEmpty
                          ? _buildEmptyState(
                              'No completed appointments',
                              'Your completed lessons will appear here',
                              Icons.check_circle_outline,
                              isDark,
                            )
                          : Column(
                              children: _buildCompletedAppointmentsList(
                                viewModel.completedAppointments,
                                viewModel,
                                isDark,
                              ),
                            ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    return Container(
      height: 120,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // Today's Lessons Card
          Expanded(
            child: _buildStatCard(
              title: "Today",
              value: viewModel.getTodayAppointmentsCount().toString(),
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF4C3575),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // This Week's Lessons Card
          Expanded(
            child: _buildStatCard(
              title: "This Week",
              value: viewModel.getThisWeekAppointmentsCount().toString(),
              icon: Icons.date_range_rounded,
              color: const Color(0xFF22C55E),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // Total Completed Card
          Expanded(
            child: _buildStatCard(
              title: "Completed",
              value: viewModel.completedAppointments.length.toString(),
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.figtree(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleSection(
    BuildContext context,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    final todayAppointments = viewModel.getTodayAppointments();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Schedule",
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('EEE, MMM d').format(DateTime.now()),
                  style: GoogleFonts.figtree(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          todayAppointments.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event_busy_outlined,
                          size: 24,
                          color: Colors.orange[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No sessions scheduled for today",
                              style: GoogleFonts.figtree(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Enjoy your free time!",
                              style: GoogleFonts.figtree(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: todayAppointments.map((appointment) {
                    final startTime = DateTime.parse(appointment.startAt);
                    final endTime = DateTime.parse(appointment.endAt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: appointment.isCompleted
                              ? [
                                  const Color(0xFF059669).withOpacity(0.9),
                                  const Color(0xFF10B981).withOpacity(0.8),
                                ]
                              : [
                                  AppColors.primary.withOpacity(0.9),
                                  AppColors.primary.withOpacity(0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: appointment.isCompleted
                                ? const Color(0xFF059669).withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.video_camera_front_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.learnerName,
                                      style: GoogleFonts.figtree(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}",
                                      style: GoogleFonts.figtree(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              appointment.isCompleted
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Completed",
                                            style: GoogleFonts.figtree(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.schedule,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getTimeStatus(startTime),
                                            style: GoogleFonts.figtree(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                          if (!appointment.isCompleted) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Reschedule functionality
                                  },
                                  icon: const Icon(
                                    Icons.event_repeat,
                                    size: 18,
                                  ),
                                  label: const Text('Reschedule'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.5)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      viewModel.navigateToAppointmentDetails(
                                          appointment.id),
                                  icon: const Icon(
                                    Icons.video_call_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Start Session'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  String _getTimeStatus(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.isNegative && difference.inHours > -1) {
      return "In Progress";
    } else if (difference.inHours < 1) {
      return "Starting Soon";
    } else if (difference.inHours < 24) {
      return "Today";
    } else {
      return "Upcoming";
    }
  }

  Widget _buildSectionHeader(String title, bool isLoading, bool isDark,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          trailing ??
              (isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.white70 : AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox()),
        ],
      ),
    );
  }

  List<Widget> _buildUpcomingAppointmentsList(
    List<Appointment> appointments,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    return appointments
        .map((appointment) {
          // Skip appointments that are already in Today's section
          if (viewModel.isAppointmentToday(appointment)) {
            return const SizedBox.shrink();
          }

          final startTime = DateTime.parse(appointment.startAt);
          final endTime = DateTime.parse(appointment.endAt);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.video_camera_front_outlined,
                          color: isDark ? Colors.white : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.learnerName,
                              style: GoogleFonts.figtree(
                                color: isDark ? Colors.white : Colors.grey[800],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    DateFormat('MMM d').format(startTime),
                                    style: GoogleFonts.figtree(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}",
                                  style: GoogleFonts.figtree(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          // Show more options
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.grey[800]!.withOpacity(0.3)
                      : Colors.grey[200],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Reschedule functionality
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_repeat,
                                size: 16,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reschedule',
                                style: GoogleFonts.figtree(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[200],
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => viewModel
                            .navigateToAppointmentDetails(appointment.id),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.launch,
                                size: 16,
                                color: isDark
                                    ? AppColors.primary.withOpacity(0.8)
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Session Details',
                                style: GoogleFonts.figtree(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.primary.withOpacity(0.8)
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        })
        .where((widget) => widget is! SizedBox)
        .toList();
  }

  List<Widget> _buildCompletedAppointmentsList(
    List<Appointment> appointments,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    return appointments.map((appointment) {
      final startTime = DateTime.parse(appointment.startAt);
      final endTime = DateTime.parse(appointment.endAt);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: isDark
                      ? Colors.greenAccent[200]
                      : const Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.learnerName,
                      style: GoogleFonts.figtree(
                        color: isDark ? Colors.white : Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat('MMM d').format(startTime),
                            style: GoogleFonts.figtree(
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}",
                          style: GoogleFonts.figtree(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View Session button
              InkWell(
                onTap: () =>
                    viewModel.navigateToAppointmentDetails(appointment.id),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'View',
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoaders() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomAppointmentList(
            contextDetails: '',
            startAt: '2023-01-01T10:00:00Z',
            endAt: '2023-01-01T11:00:00Z',
            onTap: () {},
            isLoading: true,
          ),
        ),
      ),
    );
  }

  @override
  TrainerAppointmentHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TrainerAppointmentHomeViewModel();

  @override
  void onViewModelReady(TrainerAppointmentHomeViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
