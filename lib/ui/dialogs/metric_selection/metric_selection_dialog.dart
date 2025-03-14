import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricSelectionDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const MetricSelectionDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  State<MetricSelectionDialog> createState() => _MetricSelectionDialogState();
}

class _MetricSelectionDialogState extends State<MetricSelectionDialog> {
  late Set<String> selectedMetrics;
  final Set<String> _selectedMetrics = {};

  @override
  void initState() {
    super.initState();
    final data = widget.request.data as Map<String, dynamic>;
    selectedMetrics = (data['selected'] as Set<String>? ?? {}).toSet();
    _selectedMetrics.addAll(selectedMetrics);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.request.data as Map<String, dynamic>;
    final metrics = data['metrics'] as List<String>;
    final labels = data['labels'] as Map<String, String>;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.request.title ?? 'Select Metrics',
              style: GoogleFonts.figtree(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.request.description ??
                  'Choose metrics to include in the report:',
              style: GoogleFonts.figtree(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: metrics.map((metric) {
                    return CheckboxListTile(
                      title: Text(
                        labels[metric] ?? metric,
                        style: GoogleFonts.figtree(),
                      ),
                      value: _selectedMetrics.contains(metric),
                      activeColor: AppColors.primary,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedMetrics.add(metric);
                          } else {
                            _selectedMetrics.remove(metric);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      widget.completer(DialogResponse(confirmed: false)),
                  child: Text(
                    widget.request.secondaryButtonTitle ?? 'Cancel',
                    style: GoogleFonts.figtree(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => widget.completer(
                    DialogResponse(
                      confirmed: true,
                      data: _selectedMetrics,
                    ),
                  ),
                  child: Text(
                    widget.request.mainButtonTitle ?? 'Export',
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
