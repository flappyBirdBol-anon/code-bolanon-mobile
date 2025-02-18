import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: viewModel.navigateToForgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 24),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: viewModel.loginWithEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              const _DividerWithText(text: 'or continue with'),
              const SizedBox(height: 16),
              _SocialLoginButton(
                onPressed: viewModel.loginWithGoogle,
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
                label: 'Login with Google',
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
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

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
