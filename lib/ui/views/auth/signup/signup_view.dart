import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'signup_viewmodel.dart';

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
            const SizedBox(height: 24),
            _buildCommonFields(viewModel, context),
            const SizedBox(height: 16),
            if (viewModel.selectedRole == 'trainer')
              _buildTrainerFields(viewModel, context),
            _buildTermsAndConditions(context, viewModel),
            const SizedBox(height: 24),
            _buildButtons(viewModel, context),
          ],
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
                controller: viewModel
                    .firstNameController, // You'll need to add this controller
                labelText: 'First name',
                prefixIcon: Icons.person,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: viewModel
                    .lastNameController, // You'll need to add this controller
                labelText: 'Last name',
                prefixIcon: Icons.person,
              ),
            ),
          ],
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
          onChanged: (p0) => viewModel.notifyListeners(),
          onToggleVisibility: viewModel.togglePasswordVisibility,
          focusNode: viewModel.passwordFocusNode,
          onFocusChange: viewModel.updatePasswordFocus,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 8),
        Visibility(
          visible: viewModel.isAnyPasswordFieldFocused,
          child: PasswordValidationList(
            hasMinLength: viewModel.passwordController.text.length >= 8,
            hasNumber:
                viewModel.passwordController.text.contains(RegExp(r'[0-9]')),
            hasUpperCase:
                viewModel.passwordController.text.contains(RegExp(r'[A-Z]')),
            hasLowerCase:
                viewModel.passwordController.text.contains(RegExp(r'[a-z]')),
            isMatch: viewModel.passwordController.text ==
                    viewModel.confirmPasswordController.text &&
                viewModel.passwordController.text.isNotEmpty,
          ),
        ),
        //Implement: add chips here that will be used to select a users preferred stack (for example, laravel, flutter, react, etc)
        const SizedBox(height: 16),
        _buildChips(viewModel, context),
        const SizedBox(height: 16),
        _buildRoleSelect(context, viewModel),
        const SizedBox(height: 16),
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.selectedTechStacks.isNotEmpty) ...[
                Text(
                  'Selected: ${viewModel.selectedTechStacks.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  for (String stack in viewModel.availableTechStacks)
                    FilterChip(
                      label: Text(stack),
                      selected: viewModel.selectedTechStacks.contains(stack),
                      onSelected: (bool selected) {
                        viewModel.toggleTechStack(stack);
                      },
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        fontWeight: viewModel.selectedTechStacks.contains(stack)
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: viewModel.selectedTechStacks.contains(stack)
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      pressElevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: viewModel.selectedTechStacks.contains(stack)
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400,
                        ),
                      ),
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
        const Text(
          'Trainer Information',
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
        const SizedBox(height: 24),
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
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to terms and conditions
                      //todo: navigate to terms and conditions
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

  Widget _buildRoleSelect(BuildContext context, SignupViewModel viewModel) {
    if (viewModel.selectedRole == 'trainer') {
      return Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                      text: 'Are you a Learner? Sign up ',
                      style: TextStyle(color: Colors.grey)),
                  TextSpan(
                    text: 'Here',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        viewModel.setRole('learner');
                      },
                  ),
                  TextSpan(
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        viewModel.setRole(viewModel.selectedRole == 'trainer'
                            ? 'learner'
                            : 'trainer');
                      },
                  ),
                  const TextSpan(
                    text: ' instead',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(
                    text: 'Are you a Trainer? Sign up ',
                    style: TextStyle(color: Colors.grey)),
                TextSpan(
                  text: 'Here',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      viewModel.setRole('trainer');
                    },
                ),
                const TextSpan(
                  text: ' instead',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(SignupViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        if (viewModel.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _Divider(),
          const SizedBox(height: 16),
          viewModel.termsAccepted == true && viewModel.isPasswordValid == true
              ? ElevatedButton(
                  onPressed: viewModel.signupWithEmail,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                )
              : ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(color: Colors.grey)),
                ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
      ],
    );
  }
}
