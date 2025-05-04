import 'package:code_bolanon/models/appointment_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import 'learner_schedule_viewmodel.dart';

class LearnerScheduleView extends StackedView<LearnerScheduleViewModel> {
  const LearnerScheduleView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerScheduleViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Schedule',
        showSearchButton: false,
        showNotificationButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.fetchAppointments(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildAppointmentFilters(context, viewModel, isDark),
                const SizedBox(height: 16),
                _buildAppointmentSection(context, viewModel, isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentFilters(
    BuildContext context,
    LearnerScheduleViewModel viewModel,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            'Today',
            viewModel.selectedFilter == 'Today',
            () => viewModel.setFilter('Today'),
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Upcoming',
            viewModel.selectedFilter == 'Upcoming',
            () => viewModel.setFilter('Upcoming'),
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Completed',
            viewModel.selectedFilter == 'Completed',
            () => viewModel.setFilter('Completed'),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isDark
                  ? Colors.grey[800]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDark
                    ? Colors.white
                    : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentSection(
    BuildContext context,
    LearnerScheduleViewModel viewModel,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.selectedFilter == 'Today'
                ? 'Today\'s Appointments'
                : viewModel.selectedFilter == 'Upcoming'
                    ? 'Upcoming Appointments'
                    : 'Completed Appointments',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.isLoading)
            _buildAppointmentSkeletonLoader(isDark)
          else if (!viewModel.isLoading &&
              viewModel.filteredAppointments.isEmpty)
            _buildEmptyAppointmentsView(viewModel.selectedFilter, isDark)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredAppointments.length,
              itemBuilder: (context, index) {
                final appointment = viewModel.filteredAppointments[index];
                return _buildAppointmentCard(appointment, isDark, viewModel);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyAppointmentsView(String filter, bool isDark) {
    String message;

    switch (filter) {
      case 'Today':
        message = 'No appointments scheduled for today';
        break;
      case 'Upcoming':
        message = 'No upcoming appointments';
        break;
      case 'Completed':
        message = 'No completed appointments yet';
        break;
      default:
        message = 'No appointments found';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    AppointmentModel appointment,
    bool isDark,
    LearnerScheduleViewModel viewModel,
  ) {
    final DateFormat dateFormat = DateFormat('E, MMM d');
    final DateFormat timeFormat = DateFormat('h:mm a');

    final String formattedDate = dateFormat.format(appointment.startAt);
    final String startTime = timeFormat.format(appointment.startAt);
    final String endTime = timeFormat.format(appointment.endAt);

    // Check if appointment is ongoing or completed
    final now = DateTime.now();
    final isOngoing = now.isAfter(appointment.startAt) &&
        now.isBefore(appointment.endAt) &&
        appointment.status.toLowerCase() != 'completed';
    final isCompleted = appointment.status.toLowerCase() == 'completed';

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
        border: isOngoing ? Border.all(color: Colors.green, width: 1.5) : null,
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
                    color: isCompleted
                        ? (isDark
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF10B981).withOpacity(0.1))
                        : isOngoing
                            ? Colors.green.withOpacity(0.15)
                            : (isDark
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : isOngoing
                            ? Icons.video_camera_front_outlined
                            : Icons.calendar_today_outlined,
                    color: isCompleted
                        ? (isDark
                            ? Colors.greenAccent[200]
                            : const Color(0xFF10B981))
                        : isOngoing
                            ? Colors.green
                            : (isDark ? Colors.white : Colors.blue[700]),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trainer name with balanced importance

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
                          formattedDate,
                          style: GoogleFonts.figtree(
                            color: isDark ? Colors.white70 : Colors.blue[700],
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$startTime - $endTime",
                            style: GoogleFonts.figtree(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.grey[800],
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.trainer?.fullName ?? 'Unknown Trainer',
                            style: GoogleFonts.figtree(
                              color: isDark ? Colors.white : Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // // Context details with proper spacing
                      // if (appointment.contextDetails?.isNotEmpty == true) ...[
                      //   const SizedBox(height: 8),
                      //   Text(
                      //     appointment.contextDetails!,
                      //     style: GoogleFonts.figtree(
                      //       fontSize: 15,
                      //       color: isDark ? Colors.grey[400] : Colors.grey[600],
                      //     ),
                      //     maxLines: 2,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ],
                    ],
                  ),
                ),

                // For completed appointments, show arrow forward
                if (isCompleted)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? Colors.white : Colors.blue[700],
                      size: 16,
                    ),
                    onPressed: () =>
                        viewModel.viewAppointmentDetails(appointment.id),
                  ),
              ],
            ),
          ),

          // Action buttons section
          if (!isCompleted) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[200],
            ),
            Row(
              children: [
                if (appointment.startAt.toLocal().day ==
                        DateTime.now().toLocal().day &&
                    appointment.startAt.toLocal().month ==
                        DateTime.now().toLocal().month &&
                    appointment.startAt.toLocal().year ==
                        DateTime.now().toLocal().year)
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          viewModel.launchGoogleMeet(appointment.gmeetLink),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam,
                              size: 16,
                              color: isDark ? Colors.green[300] : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Join Now',
                              style: GoogleFonts.figtree(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark ? Colors.green[300] : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (appointment.startAt.toLocal().day ==
                        DateTime.now().toLocal().day &&
                    appointment.startAt.toLocal().month ==
                        DateTime.now().toLocal().month &&
                    appointment.startAt.toLocal().year ==
                        DateTime.now().toLocal().year)
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
                    onTap: () =>
                        viewModel.viewAppointmentDetails(appointment.id),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color:
                                isDark ? Colors.grey[400] : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Details',
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? Colors.grey[400] : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentSkeletonLoader(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 160,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  LearnerScheduleViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerScheduleViewModel();

  @override
  void onViewModelReady(LearnerScheduleViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
