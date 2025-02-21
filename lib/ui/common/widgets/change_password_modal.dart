import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:code_bolanon/ui/views/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';

class ChangePasswordModal extends StatefulWidget {
  final ProfileViewModel viewModel;

  const ChangePasswordModal({Key? key, required this.viewModel})
      : super(key: key);

  @override
  _ChangePasswordModalState createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
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
              'Change Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: widget.viewModel.oldPasswordController,
                      labelText: 'Enter your old password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      obscureText: !widget.viewModel.isOldPasswordVisible,
                      onChanged: (p0) {
                        setState(() {
                          widget.viewModel.notifyPasswordInput();
                        });
                      },
                      onToggleVisibility: () {
                        setState(() {
                          widget.viewModel.toggleOldPasswordVisibility();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: widget.viewModel.newPasswordController,
                      labelText: 'Enter your new password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      obscureText: !widget.viewModel.isNewPasswordVisible,
                      onChanged: (p0) {
                        setState(() {
                          widget.viewModel.notifyPasswordInput();
                        });
                      },
                      onToggleVisibility: () {
                        setState(() {
                          widget.viewModel.toggleNewPasswordVisibility();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: widget.viewModel.confirmNewPasswordController,
                      labelText: 'Enter your password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      obscureText:
                          !widget.viewModel.isConfirmNewPasswordVisible,
                      onChanged: (p0) {
                        setState(() {
                          widget.viewModel.notifyPasswordInput();
                        });
                      },
                      onToggleVisibility: () {
                        setState(() {
                          widget.viewModel.toggleConfirmNewPasswordVisibility();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    PasswordValidationList(
                      hasMinLength:
                          widget.viewModel.newPasswordController.text.length >=
                              8,
                      hasNumber: widget.viewModel.newPasswordController.text
                          .contains(RegExp(r'[0-9]')),
                      hasUpperCase: widget.viewModel.newPasswordController.text
                          .contains(RegExp(r'[A-Z]')),
                      hasLowerCase: widget.viewModel.newPasswordController.text
                          .contains(RegExp(r'[a-z]')),
                      isMatch: widget.viewModel.newPasswordController.text ==
                              widget.viewModel.confirmNewPasswordController
                                  .text &&
                          widget
                              .viewModel.newPasswordController.text.isNotEmpty,
                    ),
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
                  onPressed: () {
                    widget.viewModel.changePassword();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
