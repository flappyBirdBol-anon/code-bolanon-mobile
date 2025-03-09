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
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your first name'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: viewModel.lastNameController,
                labelText: 'Last name',
                prefixIcon: Icons.person,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your last name'
                    : null,
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
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your email' : null,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.passwordController,
          labelText: 'Enter your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          obscureText: !viewModel.isPasswordVisible,
          onChanged: (p0) => viewModel.notifyListeners(),
          onToggleVisibility: viewModel.togglePasswordVisibility,
          focusNode: viewModel.passwordFocusNode,
          onFocusChange: viewModel.updatePasswordFocus,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.confirmPasswordController,
          labelText: 'Confirm your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          onChanged: (p0) => viewModel.notifyListeners(),
          obscureText: !viewModel.isConfirmPasswordVisible,
          onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
          focusNode: viewModel.confirmPasswordFocusNode,
          onFocusChange: viewModel.updateConfirmPasswordFocus,
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
            color: AppColors.textPrimary, // Consistent text color
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
                    color: AppColors.primary, // Use darker blue
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Wrap(
                spacing: 10.0, // Increased spacing
                runSpacing: 10.0, // Increased spacing
                children: [
                  for (String stack in viewModel.availableTechStacks)
                    CustomStackChip(
                      label: stack,
                      selected: viewModel.selectedTechStacks.contains(stack),
                      onTap: () => viewModel.toggleTechStack(stack),
                      icon: Icons.code,
                      isOutlined: true,
                    ),
                ],
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
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your organization' : null,
        ),
        const SizedBox(height: 20), // Increased spacing
        CustomTextField(
          controller: viewModel.specializationController,
          labelText: 'Specialization',
          prefixIcon: Icons.work,
          validator: (value) => value?.isEmpty ?? true
              ? 'Please enter your specialization'
              : null,
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
                      // Navigate to terms and conditions
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
              onPressed: () => viewModel.setRole('trainee'),
              icon: const Icon(Icons.person),
              label: const Text('Switch to Trainee'),
              style: OutlinedButton.styleFrom(
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
              icon: const Icon(Icons.school),
              label: const Text('Switch to Trainer'),
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
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16, // Larger text
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: viewModel.signupWithGoogle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.login),
            label: const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ],
    );
  }

  @override
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}
