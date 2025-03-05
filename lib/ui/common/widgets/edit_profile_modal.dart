import 'package:code_bolanon/ui/common/widgets/custom_image_field.dart';
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
    Navigator.pop(context);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: Container(
        width: 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                          CustomImageField(
                            height: 100,
                            width: 100,
                            isCircular: true,
                            imageUrl:
                                widget.viewModel.formattedProfilePictureUrl,
                            selectedImage:
                                widget.viewModel.selectedProfileImage,
                            placeholder: 'Add photo',
                            onImageSelected: (image) {
                              setState(() {
                                widget.viewModel
                                    .handleProfilePictureSelection(image);
                              });
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
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
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16), // Add vertical spacing
                    CustomTextField(
                      controller: widget.viewModel.lastNameController,
                      labelText: 'Last name',
                      prefixIcon: Icons.person,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your last name'
                          : null,
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
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.organizationController,
          labelText: 'Organization',
          prefixIcon: Icons.school,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your organization' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.specializationController,
          labelText: 'Specialization',
          prefixIcon: Icons.work,
          validator: (value) => value?.isEmpty ?? true
              ? 'Please enter your specialization'
              : null,
        ),
      ],
    );
  }
}
