import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_schedule_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_weekly_calendar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'learner_book_appointment_viewmodel.dart';

class LearnerBookAppointmentView
    extends StackedView<LearnerBookAppointmentViewModel> {
  final int trainerId;
  const LearnerBookAppointmentView({Key? key, required this.trainerId})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerBookAppointmentViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'Book Appointment',
        showSearchButton: false,
        showNotificationButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadAvailableSchedules();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWeeklyCalendar(
                  selectedDate: viewModel.selectedDate,
                  onDateSelected: viewModel.setSelectedDate,
                  weekDays: viewModel.getWeekDays(),
                  weekdays: viewModel.weekdays,
                  onPreviousWeek: viewModel.previousWeek,
                  onNextWeek: viewModel.nextWeek,
                  onCalendarTap: (context) => _selectDate(context, viewModel),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildAvailableSchedulesSection(context, viewModel, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSchedulesSection(
    BuildContext context,
    LearnerBookAppointmentViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Available Schedules',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
        ),
        if (viewModel.isLoading && viewModel.availableTimeSlots.isEmpty)
          _buildSkeletonLoaders(3)
        else if (viewModel.availableTimeSlots.isEmpty)
          viewModel.isSelectedDateActive(viewModel.selectedDate)
              ? _buildEmptyState(
                  'No available schedules',
                  'Check back later for new schedules',
                  isDark,
                )
              : _buildEmptyState(
                  'Past date selected',
                  'Please select a future date to view available schedules',
                  isDark,
                )
        else
          Column(
            children: viewModel.availableTimeSlots.map((slot) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomScheduleItem(
                  date: DateFormat('MMM d').format(slot.startAt),
                  startTime: DateFormat('h:mm a').format(slot.startAt),
                  endTime: DateFormat('h:mm a').format(slot.endAt),
                  isDark: isDark,
                  isBook: true,
                  id: slot.id.toString(),
                  onTap: () => _showBookingConfirmation(
                      context, viewModel, slot.id, isDark),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: isDark ? Colors.grey[400] : Colors.grey[400],
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

  Widget _buildSkeletonLoaders(int count) {
    return Column(
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(
    BuildContext context,
    LearnerBookAppointmentViewModel viewModel,
    int appointmentId,
    bool isDark,
  ) async {
    // First check for overlapping appointments
    final selectedSlot = viewModel.availableTimeSlots
        .firstWhere((slot) => slot.id == appointmentId);
    final hasOverlap = await viewModel.hasOverlappingAppointment(selectedSlot);

    if (hasOverlap) {
      // Show error dialog for overlapping appointment
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Schedule Conflict',
            style: GoogleFonts.figtree(
              color: isDark ? Colors.white : Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You already have a booked appointment that overlaps with this time slot.',
            style: GoogleFonts.figtree(
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // If no overlap, proceed with booking confirmation
    final TextEditingController contextController = TextEditingController();
    bool isContextValid = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Confirm Booking',
            style: GoogleFonts.figtree(
              color: isDark ? Colors.white : Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Would you like to book this appointment?',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contextController,
                onChanged: (value) {
                  setState(() {
                    isContextValid = value.trim().isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Booking Context *',
                  labelStyle: GoogleFonts.figtree(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                  errorText:
                      contextController.text.isEmpty ? 'Required field' : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isContextValid
                  ? () {
                      Navigator.pop(context);
                      viewModel.bookAppointment(
                          appointmentId, contextController.text);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'BOOK',
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, LearnerBookAppointmentViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.selectDateFromCalendar(picked);
    }
  }

  @override
  LearnerBookAppointmentViewModel viewModelBuilder(BuildContext context) =>
      LearnerBookAppointmentViewModel();

  @override
  void onViewModelReady(LearnerBookAppointmentViewModel viewModel) {
    viewModel.initialize(trainerId: trainerId);
    super.onViewModelReady(viewModel);
  }
}
