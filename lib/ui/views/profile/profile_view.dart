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
        title: const Text('Profile', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(viewModel),
                const SizedBox(height: 24),
                _buildInfoCard(viewModel, context),
                const SizedBox(height: 24),
                _buildActionButtons(context, viewModel), // Pass viewModel here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: viewModel.formattedProfilePictureUrl.isNotEmpty
                ? NetworkImage(viewModel.formattedProfilePictureUrl)
                : null,
            child: viewModel.formattedProfilePictureUrl.isEmpty
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            '${viewModel.firstName} ${viewModel.lastName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              viewModel.role,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ProfileViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSectionTitle('Tech Stacks'),
            TextButton(
              onPressed: () =>
                  _showUpdateModal(context, 'Manage Tech Stack', viewModel),
              child: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTechStacks(viewModel.techStacks),
        const SizedBox(height: 24),
        if (viewModel.role == 'trainer') ...[
          _buildSectionTitle('Profession'),
          const SizedBox(height: 8),
          _buildInfoRow('Specialization', viewModel.specialization),
          const SizedBox(height: 8),
          _buildInfoRow('Organization', viewModel.organization),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTechStacks(List<String> techStacks) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: techStacks
          .map((tech) => Chip(
                label: Text(tech),
                backgroundColor: Colors.grey[200],
                labelStyle: const TextStyle(color: Colors.black87),
              ))
          .toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => viewModel.showEditProfileModal(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => viewModel.showChangePasswordModal(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Colors.black87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Change Password'),
          ),
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
