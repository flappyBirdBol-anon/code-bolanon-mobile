import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'manage_stack_viewmodel.dart';

class ManageStackView extends StatelessWidget {
  const ManageStackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ViewModelBuilder<ManageStackViewModel>.reactive(
      viewModelBuilder: () => ManageStackViewModel(),
      builder: (context, viewModel, child) => Container(
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
                      Icons.code_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Manage Tech Stacks',
                    style: GoogleFonts.figtree(
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Tech Stacks',
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (viewModel.selectedTechStacks.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'No tech stacks selected',
                            style: GoogleFonts.figtree(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: viewModel.selectedTechStacks.map((techStack) {
                          return Chip(
                            label: Text(
                              techStack.tags ?? '',
                              style: GoogleFonts.figtree(
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            deleteIcon: Icon(
                              Icons.close,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onDeleted: () =>
                                viewModel.removeTechStack(techStack),
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[100],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Available Tech Stacks',
                      style: GoogleFonts.figtree(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: viewModel.availableTechStacks.map((techStack) {
                        return ActionChip(
                          label: Text(
                            techStack.tags ?? '',
                            style: GoogleFonts.figtree(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          onPressed: () => viewModel.addTechStack(techStack),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons with divider
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.figtree(
                            color:
                                isDark ? Colors.grey[400] : AppColors.primary,
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
    );
  }
}
