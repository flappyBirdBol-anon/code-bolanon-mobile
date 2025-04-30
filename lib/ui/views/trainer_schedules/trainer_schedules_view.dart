import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_appointment_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_schedule_item.dart';
import 'package:code_bolanon/ui/common/widgets/custom_weekly_calendar.dart';
import 'package:code_bolanon/ui/views/reschedule_appointment/reschedule_appointment_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'trainer_schedules_viewmodel.dart';

class TrainerSchedulesView extends StackedView<TrainerSchedulesViewModel> {
  const TrainerSchedulesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'Schedule Management',
        showSearchButton: false,
        showNotificationButton: false,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            RefreshIndicator(
              onRefresh: () async {
                await viewModel.loadAppointments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWeeklyCalendar(
                      selectedDate: viewModel.selectedDate,
                      onDateSelected: (date) => viewModel.setSelectedDate(date),
                      weekDays: viewModel.getWeekDays(),
                      weekdays: viewModel.weekdays,
                      onPreviousWeek: viewModel.previousWeek,
                      onNextWeek: viewModel.nextWeek,
                      onCalendarTap: (context) =>
                          _selectDate(context, viewModel),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 15),
                    _buildAvailableAppointmentsSection(
                        context, viewModel, isDark),
                    const SizedBox(height: 20),
                    _buildScheduledAppointmentsSection(
                        context, viewModel, isDark),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Add Schedule Form Overlay
            if (viewModel.showAddScheduleForm)
              _buildAddScheduleForm(context, viewModel, isDark),
            // Loading Indicator
            if (viewModel.isLoading && !viewModel.showAddScheduleForm)
              const Center(
                child: CircularProgressIndicator(),
              ),
            // Error Message
            if (viewModel.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Reschedule Form Overlay
            if (viewModel.showRescheduleForm &&
                viewModel.selectedAppointmentId != null)
              RescheduleAppointmentView(
                appointmentId: viewModel.selectedAppointmentId!,
                isEdit: !viewModel.isReschedulingBookedAppointment,
                onClose: () {
                  viewModel.hideRescheduleForm();
                  viewModel.loadAppointments();
                },
              ),
          ],
        ),
      ),
      floatingActionButton: Hero(
        tag: 'fab_schedule',
        child: viewModel.isSelectedDateActive(viewModel.selectedDate)
            ? AnimatedContainer(
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
                    onTap: viewModel.toggleAddScheduleForm,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAvailableAppointmentsSection(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Available Appointments',
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
                  'No available time slots',
                  'Please select add button to add availability',
                  isDark,
                )
              : _buildEmptyState(
                  'No time slots',
                  'Cannot add schedules for past dates',
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
                  isBook: false,
                  onTap: () => _showAppointmentOptions(
                      context, viewModel, slot.id.toString(), isDark),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildScheduledAppointmentsSection(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Scheduled Appointments',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
        ),
        if (viewModel.isLoading && viewModel.scheduledAppointments.isEmpty)
          _buildSkeletonLoaders(2)
        else if (viewModel.scheduledAppointments.isEmpty)
          viewModel.isSelectedDateActive(viewModel.selectedDate)
              ? _buildEmptyState(
                  'No scheduled appointments',
                  'Your booked appointments will appear here',
                  isDark,
                )
              : _buildEmptyState(
                  'No completed scheduled appointments',
                  'Please select a future date to add availability',
                  isDark,
                )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: viewModel.scheduledAppointments.map((appointment) {
                final bool isCompleted =
                    appointment.status.toLowerCase() == 'completed';
                return CustomAppointmentItem(
                  learnerName: appointment.learnerName ?? "Learner",
                  date: DateFormat('MMM d').format(appointment.startAt),
                  startTime: DateFormat('hh:mm a').format(appointment.startAt),
                  endTime: DateFormat('hh:mm a').format(appointment.endAt),
                  onViewDetails: () => viewModel
                      .navigateToAppointmentDetails(appointment.id.toString()),
                  onReschedule: isCompleted
                      ? null // Disable reschedule for completed appointments
                      : () => viewModel.showRescheduleFormForAppointment(
                          appointment.id.toString()),
                  isDark: isDark,
                  isCompleted:
                      isCompleted, // Add this property to CustomAppointmentItem
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAddScheduleForm(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: viewModel.toggleAddScheduleForm,
      child: Container(
        color: Colors.black54,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from closing the form
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_chart,
                            color: Colors.white.withOpacity(0.9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Add New Schedule',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      viewModel.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            'Set up your availability for this day.',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDateSelector(
                            context,
                            'Date',
                            viewModel.formSelectedDate,
                            (date) => viewModel.setFormSelectedDate(date),
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildTimeSelector(
                            context,
                            'Start Time',
                            viewModel.formatTimeOfDay(viewModel.startTime),
                            () => _selectTime(context, viewModel, true),
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildTimeSelector(
                            context,
                            'End Time',
                            viewModel.formatTimeOfDay(viewModel.endTime),
                            () => _selectTime(context, viewModel, false),
                            isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildPriceField(viewModel, isDark),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons with divider
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: viewModel.toggleAddScheduleForm,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  viewModel.createAvailableTimeSlot(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                backgroundColor: AppColors.primary,
                              ),
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Add Schedule',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    bool isDark,
  ) {
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

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context,
      TrainerSchedulesViewModel viewModel, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? viewModel.startTime : viewModel.endTime,
    );

    if (picked != null) {
      if (isStartTime) {
        viewModel.setStartTime(picked);
      } else {
        viewModel.setEndTime(picked);
      }
    }
  }

  Widget _buildPriceField(
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: GoogleFonts.figtree(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: viewModel.price.toString()),
          keyboardType: TextInputType.number,
          onChanged: (value) =>
              viewModel.setPrice(double.tryParse(value) ?? 500.0),
          decoration: InputDecoration(
            hintText: 'Enter price',
            prefixText: '₱ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2025, 12, 31),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: isDark ? const Color(0xFF1E293B) : Colors.white,
                      onSurface: isDark ? Colors.white : Colors.black,
                    ),
                    dialogBackgroundColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
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

  void _showAppointmentOptions(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    String appointmentId,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.event_repeat,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              title: Text(
                'Reschedule',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                viewModel.showEditForm(appointmentId);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.red[300] : Colors.red[400],
              ),
              title: Text(
                'Cancel Appointment',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showCancelConfirmation(
                    context, viewModel, appointmentId, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    String appointmentId,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Cancel Schedule',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this schedule? This action cannot be undone.',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'NO',
              style: GoogleFonts.figtree(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.postponeAppointment(appointmentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'YES, CANCEL',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  TrainerSchedulesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TrainerSchedulesViewModel();

  @override
  void onViewModelReady(TrainerSchedulesViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  Future<void> _selectDate(
      BuildContext context, TrainerSchedulesViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4C3575),
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
}
