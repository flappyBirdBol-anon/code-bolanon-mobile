import 'package:code_bolanon/models/user_model.dart';
import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_stack_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import 'learner_appointment_home_viewmodel.dart';

class LearnerAppointmentHomeView
    extends StackedView<LearnerAppointmentHomeViewModel> {
  const LearnerAppointmentHomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LearnerAppointmentHomeViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: CustomAppBar(
        title: 'Book a Session',
        showSearchButton: true,
        onSearchTap: viewModel.setSearchQuery,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => viewModel.fetchAvailableTrainers(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Section
                _buildFilterSection(context, viewModel, isDark),

                const SizedBox(height: 16),

                // Available Trainers Section
                _buildAvailableTrainersSection(context, viewModel, isDark),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    LearnerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Specialization',
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', viewModel.selectedFilter == 'All',
                    isDark, () => viewModel.setFilter('All')),
                _buildFilterChip(
                    'Mobile Dev',
                    viewModel.selectedFilter == 'Mobile Dev',
                    isDark,
                    () => viewModel.setFilter('Mobile Dev')),
                _buildFilterChip(
                    'Web Dev',
                    viewModel.selectedFilter == 'Web Dev',
                    isDark,
                    () => viewModel.setFilter('Web Dev')),
                _buildFilterChip(
                    'Backend',
                    viewModel.selectedFilter == 'Backend',
                    isDark,
                    () => viewModel.setFilter('Backend')),
                _buildFilterChip(
                    'Data Science',
                    viewModel.selectedFilter == 'Data Science',
                    isDark,
                    () => viewModel.setFilter('Data Science')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.figtree(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.grey[300] : Colors.grey[700]),
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) => onTap(),
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAvailableTrainersSection(
    BuildContext context,
    LearnerAppointmentHomeViewModel viewModel,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Trainers',
            style: GoogleFonts.figtree(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.isLoading)
            _buildTrainerSkeletonLoaders(isDark)
          else if (viewModel.availableTrainers.isEmpty)
            Center(
              child: _buildEmptyState(
                'No trainers available',
                'Check back later for available trainers',
                Icons.person_search_outlined,
                isDark,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.availableTrainers.length,
              itemBuilder: (context, index) {
                final trainer = viewModel.availableTrainers[index];
                return _buildTrainerCard(trainer, isDark, viewModel);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(UserModel trainer, bool isDark,
      LearnerAppointmentHomeViewModel viewModel) {
    // TODO: Get actual tech stacks and ratings from the API
    final techStacks = ['Flutter', 'React Native', 'iOS', 'Android'];
    const rating = 4.8;
    const reviewCount = 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                // Trainer Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: trainer.profileImage?.isNotEmpty == true
                        ? Image.network(
                            trainer.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 30,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 30,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Trainer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.fullName,
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.specialization ?? 'No specialization',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (rating > 0) ...[
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviewCount reviews)',
                              style: GoogleFonts.figtree(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'New',
                                style: GoogleFonts.figtree(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Book Button
                ElevatedButton(
                  onPressed: () => viewModel.bookSession(trainer.id!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Book',
                    style: GoogleFonts.figtree(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tech Stack Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expertise',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: techStacks.map((stack) {
                    return CustomStackChip(
                      label: stack,
                      selected: true,
                      isDark: isDark,
                      icon: Icons.code,
                      color: viewModel.getTechColor(stack, isDark),
                      textStyle: GoogleFonts.figtree(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {},
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerSkeletonLoaders(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
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
          Icon(
            icon,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.figtree(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  LearnerAppointmentHomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LearnerAppointmentHomeViewModel();

  @override
  void onViewModelReady(LearnerAppointmentHomeViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
