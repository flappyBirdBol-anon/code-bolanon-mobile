// lib/ui/views/auth/signup/signup_view.dart
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'signup_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupView extends StackedView<SignupViewModel> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, SignupViewModel viewModel, Widget? child) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleSelection(viewModel),
            const SizedBox(height: 24),
            _buildCommonFields(viewModel),
            const SizedBox(height: 16),
            if (viewModel.selectedRole == 'trainer')
              _buildTrainerFields(viewModel),
            _buildTermsAndConditions(context, viewModel),
            const SizedBox(height: 24),
            _buildButtons(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection(SignupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create an account as:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleSelectionButton(
                title: 'Trainee',
                isSelected: viewModel.selectedRole == 'trainee',
                onTap: () => viewModel.setRole('trainee'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RoleSelectionButton(
                title: 'Trainer',
                isSelected: viewModel.selectedRole == 'trainer',
                onTap: () => viewModel.setRole('trainer'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommonFields(SignupViewModel viewModel) {
    return Column(
      children: [
        CustomTextField(
          controller: viewModel.nameController,
          labelText: 'Your name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.emailController,
          labelText: 'Enter your email',
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.passwordController,
          labelText: 'Enter your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          obscureText: !viewModel.isPasswordVisible,
          onToggleVisibility: viewModel.togglePasswordVisibility,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.confirmPasswordController,
          labelText: 'Confirm your password',
          prefixIcon: Icons.lock,
          isPassword: true,
          obscureText: !viewModel.isConfirmPasswordVisible,
          onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
        ),
        const SizedBox(height: 8),
        PasswordValidationList(
          hasMinLength: viewModel.passwordController.text.length >= 8,
          hasNumber:
              viewModel.passwordController.text.contains(RegExp(r'[0-9]')),
          hasUpperCase:
              viewModel.passwordController.text.contains(RegExp(r'[A-Z]')),
          hasLowerCase:
              viewModel.passwordController.text.contains(RegExp(r'[a-z]')),
        ),
      ],
    );
  }

  Widget _buildTrainerFields(SignupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trainer Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: viewModel.certificationController,
          labelText: 'Certification',
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

  Widget _buildTermsAndConditions(
      BuildContext context, SignupViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.termsAccepted,
          onChanged: (value) => viewModel.setTermsAccepted(value ?? false),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'By agreeing to the '),
                TextSpan(
                  text: 'terms and conditions',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to terms and conditions
                    },
                ),
                const TextSpan(
                  text:
                      ', you are entering into a legally binding contract with the service provider.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(SignupViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          ElevatedButton(
            onPressed: viewModel.signupWithEmail,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Sign Up'),
          ),
          const SizedBox(height: 16),
          const _DividerWithText(text: 'or signup with'),
          const SizedBox(height: 16),
          _SocialSignupButton(
            onPressed: viewModel.signupWithGoogle,
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                ],
              ).createShader(bounds),
              child: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}

class _RoleSelectionButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectionButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;

  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialSignupButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const _SocialSignupButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          const Text('Sign up with Google'),
        ],
      ),
    );
  }
}
