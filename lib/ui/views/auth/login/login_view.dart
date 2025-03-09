import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    return GestureDetector(
      // Add GestureDetector to handle taps outside text fields
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              CustomTextField(
                controller: viewModel.emailController,
                labelText: 'Enter your email',
                prefixIcon: Icons.email,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20), // Increased spacing
              CustomTextField(
                controller: viewModel.passwordController,
                labelText: 'Enter your password',
                prefixIcon: Icons.lock,
                isPassword: true,
                obscureText: !viewModel.isPasswordVisible,
                onToggleVisibility: viewModel.togglePasswordVisibility,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  child: TextButton(
                    onPressed: viewModel.navigateToForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary, // Darker blue
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15, // Larger font
                      ),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Increased spacing
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary, // Darker blue
                    strokeWidth: 3, // Thicker progress indicator
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: viewModel.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Darker blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16, // Larger text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
