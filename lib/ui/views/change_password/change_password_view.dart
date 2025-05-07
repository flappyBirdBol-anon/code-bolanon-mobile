import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'change_password_viewmodel.dart';

class ChangePasswordView extends StackedView<ChangePasswordViewModel> {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChangePasswordViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scrollController = ScrollController();

    // Function to scroll to bottom when password fields are focused
    void scrollToBottom() {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Container(
      width: 400,
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
                    Icons.lock_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Change Password',
                  style: TextStyle(
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
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Password hint text
                  Text(
                    'Please enter your current password and choose a new password.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: viewModel.oldPasswordController,
                    labelText: 'Current Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: !viewModel.isOldPasswordVisible,
                    onChanged: (p0) => viewModel.notifyPasswordInput(),
                    onToggleVisibility: viewModel.toggleOldPasswordVisibility,
                    errorText: viewModel.oldPasswordError,
                  ),
                  const SizedBox(height: 16),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) scrollToBottom();
                    },
                    child: CustomTextField(
                      controller: viewModel.newPasswordController,
                      labelText: 'New Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      obscureText: !viewModel.isNewPasswordVisible,
                      onChanged: (p0) => viewModel.notifyPasswordInput(),
                      onToggleVisibility: viewModel.toggleNewPasswordVisibility,
                      errorText: viewModel.newPasswordError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus) scrollToBottom();
                    },
                    child: CustomTextField(
                      controller: viewModel.confirmNewPasswordController,
                      labelText: 'Confirm New Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      obscureText: !viewModel.isConfirmNewPasswordVisible,
                      onChanged: (p0) => viewModel.notifyPasswordInput(),
                      onToggleVisibility:
                          viewModel.toggleConfirmNewPasswordVisibility,
                      errorText: viewModel.confirmNewPasswordError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PasswordValidationList(
                    hasMinLength: viewModel.hasMinLength,
                    hasNumber: viewModel.hasNumber,
                    hasUpperCase: viewModel.hasUpperCase,
                    hasLowerCase: viewModel.hasLowerCase,
                    isMatch: viewModel.isMatch,
                  ),
                ],
              ),
            ),
          ),

          // Action buttons with divider
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: viewModel.isBusy
                          ? null
                          : () async {
                              final result = await viewModel.changePassword();
                              if (context.mounted &&
                                  result['success'] == true) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: AppColors.primary,
                      ),
                      child: viewModel.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  ChangePasswordViewModel viewModelBuilder(BuildContext context) =>
      ChangePasswordViewModel();
}
