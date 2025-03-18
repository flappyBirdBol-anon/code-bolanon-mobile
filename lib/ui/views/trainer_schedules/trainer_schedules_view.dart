import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
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
      appBar: const CustomAppBar(
        title: 'Schedule Management',
        showSearchButton: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchAvailableTimeSlots();
                await viewModel.fetchScheduledAppointments();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarSection(context, viewModel, isDark),
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

            // Reschedule Form Overlay
            if (viewModel.showRescheduleForm)
              _buildRescheduleForm(context, viewModel, isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4C3575),
        onPressed: viewModel.toggleAddScheduleForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarSection(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    final weekDays = viewModel.getWeekDays();

    return Container(
      margin: const EdgeInsets.all(16),
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
          // Calendar Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: viewModel.previousWeek,
                  icon: Icon(
                    Icons.chevron_left,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    size: 28,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d').format(weekDays.last)}',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _selectDate(context, viewModel),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: isDark ? Colors.white70 : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: viewModel.nextWeek,
                  icon: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Days of Week
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = weekDays[index];
                final isToday = _isToday(date);
                final isSelected = _isSameDay(date, viewModel.selectedDate);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.selectDate(date, index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFF4C3575)
                                : const Color(0xFF8BC34A))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            viewModel.weekdays[index],
                            style: GoogleFonts.figtree(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isToday && !isSelected
                                  ? (isDark
                                      ? Colors.grey.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1))
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                date.day.toString(),
                                style: GoogleFonts.figtree(
                                  fontSize: 16,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : Colors.grey[800]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),
        ],
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
          _buildEmptyState(
            'No available time slots',
            'Tap the + button to add new availability',
            isDark,
          )
        else
          Column(
            children: viewModel.availableTimeSlots.map((slot) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF8BC34A).withOpacity(0.2)
                                  : const Color(0xFF8BC34A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.access_time,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF8BC34A),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${slot.startTime} - ${slot.endTime}',
                            style: GoogleFonts.figtree(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _showTimeSlotOptions(
                            context, viewModel, slot.id, isDark),
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
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
          _buildEmptyState(
            'No scheduled appointments',
            'Your booked appointments will appear here',
            isDark,
          )
        else
          Column(
            children: viewModel.scheduledAppointments.map((appointment) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.white),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${DateFormat('MMM d').format(appointment.date)} | ${appointment.startTime} - ${appointment.endTime}',
                                  style: GoogleFonts.figtree(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              _showAppointmentOptions(
                                  context, viewModel, appointment.id, isDark);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black12 : Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  viewModel.showRescheduleFormForAppointment(
                                      appointment.id),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                          Container(
                            height: 24,
                            width: 1,
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _showPostponeConfirmation(
                                    context, viewModel, appointment.id, isDark);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: isDark
                                          ? Colors.amber[400]
                                          : Colors.amber[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Postpone',
                                      style: GoogleFonts.figtree(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.amber[400]
                                            : Colors.amber[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
              width: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Add Schedule',
                      style: GoogleFonts.figtree(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ),
                  Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy')
                              .format(viewModel.selectedDate),
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: viewModel.toggleAddScheduleForm,
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.figtree(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: viewModel.addAvailableTimeSlot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3575),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'ADD',
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
  }

  Widget _buildRescheduleForm(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: viewModel.hideRescheduleForm,
      child: Container(
        color: Colors.black54,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from closing the form
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Reschedule',
                      style: GoogleFonts.figtree(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ),
                  Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy')
                              .format(viewModel.selectedDate),
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: viewModel.hideRescheduleForm,
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.figtree(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: viewModel.updateAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C3575),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'SAVE',
                            style: GoogleFonts.figtree(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                viewModel.showRescheduleFormForAppointment(appointmentId);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.schedule,
                color: isDark ? Colors.amber[400] : Colors.amber[700],
              ),
              title: Text(
                'Postpone',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPostponeConfirmation(
                    context, viewModel, appointmentId, isDark);
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

  void _showPostponeConfirmation(
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
          'Postpone Appointment',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to postpone this appointment? The learner will be notified.',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
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
            onPressed: () {
              Navigator.pop(context);
              viewModel.postponeAppointment(appointmentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'POSTPONE',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          'Cancel Appointment',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
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
              viewModel.postponeAppointment(
                  appointmentId); // Reusing postpone for cancel
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  void _showTimeSlotOptions(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    String slotId,
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
                Icons.edit,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              title: Text(
                'Edit Time Slot',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                viewModel.openEditScheduleForm(slotId);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: isDark ? Colors.red[300] : Colors.red[400],
              ),
              title: Text(
                'Delete Time Slot',
                style: GoogleFonts.figtree(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, viewModel, slotId, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TrainerSchedulesViewModel viewModel,
    String slotId,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Delete Time Slot',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this time slot? This action cannot be undone.',
          style: GoogleFonts.figtree(
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
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
            onPressed: () {
              Navigator.pop(context);
              viewModel.removeTimeSlot(slotId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'DELETE',
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
