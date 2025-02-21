import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/views/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';

class EditProfileModal extends StatefulWidget {
  final ProfileViewModel viewModel;

  const EditProfileModal({Key? key, required this.viewModel}) : super(key: key);

  @override
  _EditProfileModalState createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  Future<void> _saveProfile() async {
    final result = await widget.viewModel.updateProfile();
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: widget.viewModel
                                    .formattedProfilePictureUrl.isNotEmpty
                                ? NetworkImage(
                                    widget.viewModel.formattedProfilePictureUrl)
                                : null,
                            child: widget.viewModel.formattedProfilePictureUrl
                                    .isEmpty
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: widget.viewModel.firstNameController,
                      labelText: 'First name',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(width: 16),
                    CustomTextField(
                      controller: widget.viewModel.lastNameController,
                      labelText: 'Last name',
                      prefixIcon: Icons.person,
                    ),
                    if (widget.viewModel.role == 'trainer')
                      _buildTrainerFields(widget.viewModel, context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerFields(ProfileViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Profession',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: viewModel.organizationController,
          labelText: 'Organization',
          prefixIcon: Icons.school,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.specializationController,
          labelText: 'Specialization',
          prefixIcon: Icons.work,
        ),
      ],
    );
  }
}
