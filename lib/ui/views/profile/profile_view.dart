import 'package:animate_do/animate_do.dart';
import 'package:code_bolanon/ui/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tech Stacks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            IconButton(
              onPressed: () =>
                  _showUpdateModal(context, 'Manage Tech Stack', viewModel),
              icon: const Icon(Icons.edit, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4C3575).withOpacity(0.1),
                foregroundColor: const Color(0xFF4C3575),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.techStacks
              .map((tech) => FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tech,
                        style: const TextStyle(
                          color: Color(0xFF2D3142),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
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
