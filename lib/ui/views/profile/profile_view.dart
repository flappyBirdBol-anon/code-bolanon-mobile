import 'package:animate_do/animate_do.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: 'Profile',
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () async => viewModel.initialised,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(viewModel, theme),
              _buildMainContent(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'profile_image',
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45, // Reduced from 60
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      backgroundImage: viewModel
                              .formattedProfilePictureUrl.isNotEmpty
                          ? NetworkImage(viewModel.formattedProfilePictureUrl)
                          : null,
                      child: viewModel.formattedProfilePictureUrl.isEmpty
                          ? Icon(Icons.person,
                              size: 45,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${viewModel.firstName} ${viewModel.lastName}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.email,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                viewModel.role.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTechStackSection(viewModel, context),
          if (viewModel.role == 'trainer') ...[
            const SizedBox(height: 32),
            _buildProfessionalDetails(viewModel, context),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(context, viewModel),
          const SizedBox(height: 24),
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
              "Technical Skills",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  _showUpdateModal(context, 'Manage Tech Stack', viewModel),
              icon: Icon(
                Icons.add,
                size: 16,
                color: theme.primaryColor,
              ),
              label: Text(
                "Add Skills",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.primaryColor,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: isDark
                    ? theme.primaryColor.withOpacity(0.1)
                    : theme.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Wrap(
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

  Widget _buildProfessionalDetails(
      ProfileViewModel viewModel, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Specialization', viewModel.specialization),
          const SizedBox(height: 16),
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
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildActionButton(
          'Edit Profile',
          Icons.edit_outlined,
          () => viewModel.showEditProfileModal(context),
          theme.primaryColor,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Change Password',
          Icons.lock_outline,
          () => viewModel.showChangePasswordModal(context),
          isDark ? const Color(0xFF64748B) : const Color(0xFF334155),
          isDark,
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed,
      Color color, bool isDark) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDark ? color.withOpacity(0.9) : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: isDark ? color.withOpacity(0.9) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
