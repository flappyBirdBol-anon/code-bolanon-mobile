import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_stack_chip.dart';
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'signup_viewmodel.dart';

class SignupView extends StackedView<SignupViewModel> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, SignupViewModel viewModel, Widget? child) {
    return GestureDetector(
      // Add GestureDetector to handle taps outside text fields
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
        // Hide password validation checklist
        if (viewModel.isAnyPasswordFieldFocused) {
          viewModel.unfocusPasswordFields();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildCommonFields(viewModel, context),
              const SizedBox(height: 20), // Increased spacing
              if (viewModel.selectedRole == 'trainer')
                _buildTrainerFields(viewModel, context),
              _buildTermsAndConditions(context, viewModel),
              const SizedBox(height: 24),
              _buildButtons(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonFields(SignupViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: viewModel.firstNameController,
                labelText: 'First name',
                prefixIcon: Icons.person,
                errorText: viewModel.firstNameError,
                onChanged: viewModel.validateFirstName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: viewModel.lastNameController,
                labelText: 'Last name',
                prefixIcon: Icons.person,
                errorText: viewModel.lastNameError,
                onChanged: viewModel.validateLastName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.emailController,
          labelText: 'Enter your email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          errorText: viewModel.emailError,
          onChanged: viewModel.validateEmail,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.passwordController,
          labelText: 'Enter your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          obscureText: !viewModel.isPasswordVisible,
          onChanged: (value) {
            viewModel.validatePassword(value);
            viewModel.notifyListeners();
          },
          onToggleVisibility: viewModel.togglePasswordVisibility,
          focusNode: viewModel.passwordFocusNode,
          onFocusChange: viewModel.updatePasswordFocus,
          errorText: viewModel.passwordError,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.confirmPasswordController,
          labelText: 'Confirm your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          onChanged: (value) {
            viewModel.validateConfirmPassword(value);
            viewModel.notifyListeners();
          },
          obscureText: !viewModel.isConfirmPasswordVisible,
          onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
          focusNode: viewModel.confirmPasswordFocusNode,
          onFocusChange: viewModel.updateConfirmPasswordFocus,
          errorText: viewModel.confirmPasswordError,
        ),
        const SizedBox(height: 12),
        Visibility(
          visible: viewModel.isAnyPasswordFieldFocused,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: PasswordValidationList(
                hasMinLength: viewModel.passwordController.text.length >= 8,
                hasNumber: viewModel.passwordController.text
                    .contains(RegExp(r'[0-9]')),
                hasUpperCase: viewModel.passwordController.text
                    .contains(RegExp(r'[A-Z]')),
                hasLowerCase: viewModel.passwordController.text
                    .contains(RegExp(r'[a-z]')),
                isMatch: viewModel.passwordController.text ==
                        viewModel.confirmPasswordController.text &&
                    viewModel.passwordController.text.isNotEmpty,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20), // Increased spacing
        _buildChips(viewModel, context),
        const SizedBox(height: 20), // Increased spacing
        _buildRoleSelect(context, viewModel),
        const SizedBox(height: 20), // Increased spacing
      ],
    );
  }

  Widget _buildChips(SignupViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your preferred tech stack:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.selectedTechStacks.isNotEmpty) ...[
                Text(
                  'Selected: ${viewModel.selectedTechStacks.length}',
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (viewModel.isBusy)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    for (String stack in viewModel.availableTechStacks)
                      CustomStackChip(
                        label: stack,
                        selected: viewModel.isStackSelected(stack),
                        onTap: () => viewModel.toggleTechStack(stack),
                        icon: Icons.code,
                        isOutlined: true,
                      ),
                  ],
                ),
              if (viewModel.techStackError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    viewModel.techStackError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerFields(SignupViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trainer Information',
          style: GoogleFonts.figtree(
            fontSize: 18, // Larger heading
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, // Consistent text color
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.organizationController,
          labelText: 'Organization',
          prefixIcon: Icons.school,
          errorText: viewModel.organizationError,
          onChanged: viewModel.validateOrganization,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.specializationController,
          labelText: 'Specialization',
          prefixIcon: Icons.work,
          errorText: viewModel.specializationError,
          onChanged: viewModel.validateSpecialization,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTermsAndConditions(
      BuildContext context, SignupViewModel viewModel) {
    return Row(
      children: [
        SizedBox(
          width: 24, // Larger checkbox area
          height: 24,
          child: Checkbox(
            value: viewModel.termsAccepted,
            activeColor: AppColors.primary, // Use darker blue
            onChanged: (value) => viewModel.setTermsAccepted(value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14, // Slightly larger text
                  ),
              children: [
                TextSpan(
                    text: 'By agreeing to the ',
                    style: GoogleFonts.figtree(color: Colors.grey)),
                TextSpan(
                  text: 'terms and conditions',
                  style: GoogleFonts.figtree(
                    color: AppColors.primary, // Use darker blue
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      viewModel.navigateToTermsAndConditions();
                    },
                ),
                TextSpan(
                  text:
                      ', you are entering into a legally binding contract with the service provider.',
                  style: GoogleFonts.figtree(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelect(BuildContext context, SignupViewModel viewModel) {
    if (viewModel.selectedRole == 'trainer') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => viewModel.setRole('learner'),
              icon: const Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              label: Text(
                'Switch to Learner', // Updated from 'Trainee' to 'Learner'
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                elevation: 1,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => viewModel.setRole('trainer'),
              icon: const Icon(Icons.school, color: AppColors.primary),
              label: Text(
                'Switch to Trainer',
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButtons(SignupViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary, // Darker blue
              strokeWidth: 3, // Thicker progress indicator
            ),
          )
        else ...[
          ElevatedButton(
            onPressed: viewModel.signupWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Darker blue
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Sign Up',
              style: GoogleFonts.figtree(
                fontSize: 16, // Larger text
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}
