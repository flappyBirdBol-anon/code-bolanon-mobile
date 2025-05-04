import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_appointment_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_appointment_list.dart';
import 'package:code_bolanon/ui/common/widgets/custom_schedule_item.dart';
import 'package:code_bolanon/ui/views/reschedule_appointment/reschedule_appointment_view.dart';
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
      appBar: const CustomAppBar(
        title: 'Appointments',
        showNotificationButton: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => viewModel.fetchAppointments(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A)
                                ]
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
                                  'Welcome to Your Appointments',
                                  style: GoogleFonts.figtree(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 600
                                            ? 20
                                            : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Overview of your appointments and sessions',
                                  style: GoogleFonts.figtree(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 600
                                            ? 14
                                            : 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              viewModel
                                  .navigateToSchedules(); // Ensure this method does not require arguments
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats Section
                    Container(
                      height: 135, // Increased height from 120 to 135
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Today',
                              '${viewModel.getTodayAppointmentsCount()}',
                              Icons.calendar_today,
                              AppColors.primary,
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              'This Week',
                              '${viewModel.getThisWeekAppointmentsCount()}',
                              Icons.date_range,
                              AppColors.primary,
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              'Completed',
                              '${viewModel.completedAppointments.length}',
                              Icons.check_circle,
                              AppColors.primary,
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    _buildAvailableSchedules(context, viewModel, isDark),
                    const SizedBox(height: 15),
                    _buildSectionHeader('Appointments', viewModel.isLoading,
                        isDark, false, viewModel),
                    const SizedBox(height: 15),

                    // Filter Chips Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'All',
                              viewModel.currentFilter == AppointmentFilter.all,
                              () => viewModel.setFilter(AppointmentFilter.all),
                              isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Today',
                              viewModel.currentFilter ==
                                  AppointmentFilter.today,
                              () =>
                                  viewModel.setFilter(AppointmentFilter.today),
                              isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Upcoming',
                              viewModel.currentFilter ==
                                  AppointmentFilter.upcoming,
                              () => viewModel
                                  .setFilter(AppointmentFilter.upcoming),
                              isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Completed',
                              viewModel.currentFilter ==
                                  AppointmentFilter.completed,
                              () => viewModel
                                  .setFilter(AppointmentFilter.completed),
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Conditional Content Based on Filter
                    if (viewModel.currentFilter == AppointmentFilter.all) ...[
                      _buildTodayScheduleSection(context, viewModel, isDark),
                      const SizedBox(height: 15),
                      _buildUpcomingSection(viewModel, isDark, context),
                      const SizedBox(height: 20),
                      _buildCompletedSection(viewModel, isDark, context),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: _buildFilteredAppointmentsList(
                            viewModel.getFilteredAppointments(),
                            viewModel,
                            isDark,
                            context,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Reschedule Form Overlay
            if (viewModel.showRescheduleForm &&
                viewModel.selectedAppointmentId != null)
              RescheduleAppointmentView(
                appointmentId: viewModel.selectedAppointmentId!,
                isEdit:
                    false, // We're in the trainer home, so we're only rescheduling
                onClose: () {
                  viewModel.hideRescheduleForm();
                },
              ),
          ],
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(context, viewModel),
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
          _buildSectionHeader(
              "Today", viewModel.isLoading, isDark, true, viewModel),
          const SizedBox(height: 12),
          viewModel.isLoading && todayAppointments.isEmpty
              ? _buildSkeletonLoaders()
              : todayAppointments.isEmpty
                  ? Center(
                      child: _buildEmptyState(
                      'No appointments today',
                      'Enjoy your day!',
                      Icons.event_busy_outlined,
                      isDark,
                    ))
                  : Column(
                      children: _buildFilteredAppointmentsList(
                        todayAppointments,
                        viewModel,
                        isDark,
                        context,
                      ),
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
      bool isToday, TrainerAppointmentHomeViewModel viewModel,
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
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  List<Widget> _buildAvailableScheduleList(
    List<Appointment> appointments,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
    BuildContext context,
  ) {
    // Ensure we're only working with available schedules
    appointments.sort((a, b) =>
        DateTime.parse(a.startAt).compareTo(DateTime.parse(b.startAt)));

    return appointments
        .take(3)
        .map((appointment) {
          final startTime = DateTime.parse(appointment.startAt);
          final endTime = DateTime.parse(appointment.endAt);

          return CustomScheduleItem(
            date: DateFormat('MMM d').format(startTime),
            startTime: DateFormat('h:mm a').format(startTime),
            endTime: DateFormat('h:mm a').format(endTime),
            isDark: isDark,
            isBook: false,
            id: appointment.id,
            onReschedule: () => viewModel.rescheduleAppointment(appointment.id),
            onCancel: () => _showPostponeConfirmation(
              context,
              viewModel,
              appointment.id,
              isDark,
            ),
          );
        })
        .where((widget) => widget is! SizedBox)
        .toList();
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    Color cardColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8), // Reduced vertical padding from 16 to 12
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.1)
              : Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Add this to make column wrap content
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6), // Reduced from 8 to 6
          Text(
            value,
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4 to 2
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostponeConfirmation(
    BuildContext context,
    TrainerAppointmentHomeViewModel viewModel,
    String appointmentId,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Cancel Schedule',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this available schedule?',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[800],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.postponeAppointment(appointmentId);
              Navigator.of(context).pop();
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(
                color: isDark ? Colors.redAccent : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : AppColors.primary)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.figtree(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredAppointmentsList(
    List<Appointment> appointments,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
    BuildContext context,
  ) {
    if (appointments.isEmpty) {
      return [
        _buildEmptyState(
          'No appointments found',
          'No appointments match the selected filter',
          Icons.event_busy_outlined,
          isDark,
        ),
      ];
    }

    return appointments.map((appointment) {
      final startTime = DateTime.parse(appointment.startAt);
      final endTime = DateTime.parse(appointment.endAt);

      // For booked/ongoing appointments, provide reschedule but no cancel option
      final bool isOngoing =
          !appointment.isCompleted && appointment.learnerName.isNotEmpty;

      return CustomAppointmentItem(
        learnerName: appointment.learnerName,
        date: DateFormat('MMM d').format(startTime),
        startTime: DateFormat('h:mm a').format(startTime),
        endTime: DateFormat('h:mm a').format(endTime),
        isCompleted: appointment.isCompleted,
        isDark: isDark,
        onViewDetails: () =>
            viewModel.navigateToAppointmentDetails(appointment.id),
        onReschedule: appointment.isCompleted
            ? null
            : () => viewModel.rescheduleAppointment(appointment.id),
        // Only provide cancel for available schedules (not booked appointments)
        onCancel: (appointment.isCompleted || isOngoing)
            ? null
            : () => _showPostponeConfirmation(
                context, viewModel, appointment.id, isDark),
      );
    }).toList();
  }

  Widget _buildUpcomingSection(
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
    BuildContext context,
  ) {
    final upcomingAppointments = viewModel.upcomingAppointments
        .where((appointment) => !viewModel.isAppointmentToday(appointment))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Upcoming', viewModel.isLoading, isDark, false, viewModel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: viewModel.isLoading && upcomingAppointments.isEmpty
              ? _buildSkeletonLoaders()
              : upcomingAppointments.isEmpty
                  ? Center(
                      child: _buildEmptyState(
                      'No upcoming appointments',
                      'Your upcoming appointments will appear here',
                      Icons.event_note_outlined,
                      isDark,
                    ))
                  : Column(
                      children: _buildFilteredAppointmentsList(
                        upcomingAppointments,
                        viewModel,
                        isDark,
                        context,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCompletedSection(TrainerAppointmentHomeViewModel viewModel,
      bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Completed', viewModel.isLoading, isDark, false, viewModel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: viewModel.isLoading && viewModel.completedAppointments.isEmpty
              ? _buildSkeletonLoaders()
              : viewModel.completedAppointments.isEmpty
                  ? Center(
                      child: _buildEmptyState(
                      'No completed appointments',
                      'Your completed appointments will appear here',
                      Icons.check_circle_outline,
                      isDark,
                    ))
                  : Column(
                      children: _buildFilteredAppointmentsList(
                          viewModel.completedAppointments,
                          viewModel,
                          isDark,
                          context),
                    ),
        ),
      ],
    );
  }

  Widget _buildAvailableSchedules(
    BuildContext context,
    TrainerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    final availableSchedules = viewModel.availableSchedules.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Available Schedules', viewModel.isLoading, isDark,
            false, viewModel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: viewModel.isLoading && availableSchedules.isEmpty
              ? _buildSkeletonLoaders()
              : availableSchedules.isEmpty
                  ? Center(
                      child: _buildEmptyState(
                      'No available schedules',
                      'Please create available schedules',
                      Icons.event_note_outlined,
                      isDark,
                    ))
                  : Column(children: [
                      Column(
                        children: _buildAvailableScheduleList(
                          availableSchedules,
                          viewModel,
                          isDark,
                          context,
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: viewModel.navigateToSchedules,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'View more',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
        ),
      ],
    );
  }

  Widget _buildAnimatedFAB(
      BuildContext context, TrainerAppointmentHomeViewModel viewModel) {
    return Hero(
      tag: 'fab_appoinmtments',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha((0.4 * 255).toInt()),
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
            onTap: () => viewModel.navigateToSchedules(),
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.calendar_today_rounded,
                  color: Colors.white, size: 28),
            ),
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
