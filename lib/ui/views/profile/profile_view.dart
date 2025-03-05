import 'package:animate_do/animate_do.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:code_bolanon/ui/common/widgets/custom_button.dart';
import 'package:code_bolanon/ui/common/widgets/custom_stack_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Profile',
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(viewModel),
            _buildMainContent(viewModel, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Hero(
              tag: 'profile_image',
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4C3575),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFE9ECEF),
                  backgroundImage:
                      viewModel.formattedProfilePictureUrl.isNotEmpty
                          ? NetworkImage(viewModel.formattedProfilePictureUrl)
                          : null,
                  child: viewModel.formattedProfilePictureUrl.isEmpty
                      ? const Icon(Icons.person,
                          size: 50, color: Color(0xFF4C3575))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${viewModel.firstName} ${viewModel.lastName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9BA4B5),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4C3575).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                viewModel.role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4C3575),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTechStackSection(viewModel, context),
          if (viewModel.role == 'trainer') ...[
            const SizedBox(height: 24),
            _buildProfessionalDetails(viewModel),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildTechStackSection(
      ProfileViewModel viewModel, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Add the same language color mapping as trainer home view
    final Map<String, Color> languageColors = {
      'JavaScript': Colors.yellow[700]!,
      'Python': Colors.blue[700]!,
      'Java': Colors.orange[800]!,
      'Ruby': Colors.red[700]!,
      'C#': Colors.purple[700]!,
      'PHP': Colors.indigo[600]!,
      'Swift': Colors.orange[600]!,
      'Kotlin': Colors.purple[600]!,
      'Go': Colors.cyan[700]!,
      'TypeScript': Colors.blue[600]!,
      'C++': Colors.blue[800]!,
      'Rust': Colors.deepOrange[800]!,
      'Development': Colors.teal[700]!,
      'Design': Colors.pink[600]!,
      'Tech': Colors.indigo[500]!,
      'Marketing': Colors.green[700]!,
      'Business': Colors.amber[800]!,
      'Sports': Colors.lightBlue[700]!,
      'IT Software': Colors.deepPurple[600]!,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Stack",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  _showUpdateModal(context, 'Manage Tech Stack', viewModel),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                "Add",
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTechStacks(viewModel, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildTechStacks(ProfileViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: viewModel.techStacks.map((tech) {
        return CustomStackChip(
          label: tech,
          selected: true,
          isDark: isDark,
          icon: Icons.code,
          color: viewModel.getTechColor(tech, theme),
          textStyle: GoogleFonts.firaCode(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildProfessionalDetails(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Specialization', viewModel.specialization),
          const SizedBox(height: 8),
          _buildDetailRow('Organization', viewModel.organization),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9BA4B5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileViewModel viewModel) {
    return Column(
      children: [
        CustomButton(
          text: 'Edit Profile',
          icon: Icons.edit,
          onPressed: () async {
            viewModel.showEditProfileModal(context);
          },
          backgroundColor: const Color(0xFF4C3575),
          width: double.infinity,
          height: 48,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Change Password',
          icon: Icons.lock_outline,
          onPressed: () => viewModel.showChangePasswordModal(context),
          backgroundColor: const Color.fromARGB(255, 147, 154, 185),
          width: double.infinity,
          height: 48,
        ),
      ],
    );
  }

  void _showUpdateModal(
      BuildContext context, String title, ProfileViewModel viewModel) {
    if (title == 'Manage Tech Stack') {
      viewModel.showTechStackModal(context);
    } else if (title == 'Edit Profile') {
      viewModel.showEditProfileModal(context);
    } else if (title == 'Change Password') {
      viewModel.showChangePasswordModal(context);
    }
  }

  @override
  ProfileViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfileViewModel();
}
