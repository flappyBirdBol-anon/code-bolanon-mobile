import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'reschedule_appointment_viewmodel.dart';

class RescheduleAppointmentView extends StatelessWidget {
  final String appointmentId;
  final bool isEdit;
  final VoidCallback? onClose;

  const RescheduleAppointmentView({
    Key? key,
    required this.appointmentId,
    this.isEdit = false,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ViewModelBuilder<RescheduleAppointmentViewModel>.reactive(
      viewModelBuilder: () => RescheduleAppointmentViewModel(),
      onViewModelReady: (viewModel) =>
          viewModel.initialize(appointmentId, isEdit),
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: onClose ?? () => Navigator.of(context).pop(),
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
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
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
                                isEdit
                                    ? Icons.edit_calendar
                                    : Icons.event_repeat,
                                color: Colors.white.withOpacity(0.9),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isEdit
                                  ? 'Edit Schedule'
                                  : 'Reschedule Appointment',
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
                                          style: GoogleFonts.figtree(
                                            color: Colors.red[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                isEdit
                                    ? 'Update the schedule details below.'
                                    : 'Please select a new date and time for this appointment.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildDateSelector(
                                context,
                                viewModel,
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
                              if (isEdit) ...[
                                const SizedBox(height: 16),
                                _buildPriceField(viewModel, isDark),
                              ],
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
                                  onPressed: onClose ??
                                      () => Navigator.of(context).pop(),
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
                                  onPressed: viewModel.hasChanges
                                      ? () async {
                                          final result = await viewModel
                                              .updateAppointment();
                                          if (result['success'] &&
                                              onClose != null) {
                                            onClose!(); // Call the onClose callback which will trigger parent view refresh
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor: isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
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
                                      : Text(
                                          isEdit
                                              ? 'Save Changes'
                                              : 'Reschedule',
                                          style: TextStyle(
                                            color: viewModel.hasChanges
                                                ? Colors.white
                                                : isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
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
      },
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    RescheduleAppointmentViewModel viewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
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
              initialDate: viewModel.selectedDate,
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
              viewModel.setSelectedDate(picked);
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
                  DateFormat('EEEE, MMMM d, yyyy')
                      .format(viewModel.selectedDate),
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

  Widget _buildPriceField(
    RescheduleAppointmentViewModel viewModel,
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

  Future<void> _selectTime(
    BuildContext context,
    RescheduleAppointmentViewModel viewModel,
    bool isStartTime,
  ) async {
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
}
