import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'appointment_details_viewmodel.dart';

class AppointmentDetailsView extends StackedView<AppointmentDetailsViewModel> {
  final String appointmentId;
  const AppointmentDetailsView({Key? key, required this.appointmentId})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AppointmentDetailsViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'Appointment Details',
        showSearchButton: false,
        showNotificationButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.appointment == null
              ? Center(
                  child: Text(
                    'Appointment not found',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date/Time Header with Status Chip
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE, MMMM d, yyyy')
                                      .format(viewModel.appointment!.startAt),
                                  style: GoogleFonts.figtree(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                            viewModel.appointment!.status)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    viewModel.appointment!.status.toUpperCase(),
                                    style: GoogleFonts.figtree(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(
                                          viewModel.appointment!.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${DateFormat('h:mm a').format(viewModel.appointment!.startAt)} - ${DateFormat('h:mm a').format(viewModel.appointment!.endAt)}',
                              style: GoogleFonts.figtree(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'P ${viewModel.appointment!.price.toStringAsFixed(2)}',
                              style: GoogleFonts.figtree(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue[200],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Consultation Details with GMeet Link and Participant Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details',
                              style: GoogleFonts.figtree(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailItem(
                              isDark,
                              viewModel.isTrainerView ? 'Learner' : 'Trainer',
                              viewModel.isTrainerView
                                  ? viewModel.appointment!.learnerName ??
                                      'Unknown'
                                  : viewModel.appointment!.trainer?.fullName ??
                                      'Unknown',
                              Icons.person,
                            ),
                            if (viewModel.appointment!.contextDetails !=
                                null) ...[
                              const SizedBox(height: 12),
                              _buildDetailItem(
                                isDark,
                                'Context',
                                viewModel.appointment!.contextDetails!,
                                Icons.description,
                              ),
                            ],
                            if (viewModel.isBooked) ...[
                              const SizedBox(height: 12),
                              _buildDetailItem(
                                isDark,
                                'Meet Link',
                                viewModel.appointment!.gmeetLink ??
                                    'Not available',
                                Icons.video_camera_front,
                                isLink: true,
                                onTap: viewModel.launchGoogleMeet,
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (viewModel.canReschedule &&
                          !viewModel.isCompleted) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Actions',
                                style: GoogleFonts.figtree(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: viewModel.showRescheduleForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Reschedule Appointment',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.lightGreenAccent;
      case 'ongoing':
        return const Color.fromARGB(255, 150, 222, 255);
      case 'available':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailItem(
    bool isDark,
    String label,
    String value,
    IconData icon, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    final textWidget = Text(
      value,
      style: GoogleFonts.figtree(
        fontSize: 16,
        color: isLink
            ? AppColors.primary
            : (isDark ? Colors.white : Colors.grey[800]),
        decoration: isLink ? TextDecoration.underline : null,
      ),
    );

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white70 : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              isLink
                  ? GestureDetector(
                      onTap: onTap,
                      child: textWidget,
                    )
                  : textWidget,
            ],
          ),
        ),
      ],
    );
  }

  @override
  AppointmentDetailsViewModel viewModelBuilder(BuildContext context) =>
      AppointmentDetailsViewModel();

  @override
  void onViewModelReady(AppointmentDetailsViewModel viewModel) {
    viewModel.initialize(appointmentId);
    super.onViewModelReady(viewModel);
  }
}
