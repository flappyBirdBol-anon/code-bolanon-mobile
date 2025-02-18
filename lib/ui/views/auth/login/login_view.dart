import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/views/auth/widgets/social_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

import '../widgets/divider_widget.dart';
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
                onPressed: viewModel.login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Login',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              ),
              const SizedBox(height: 16),
              const DividerWithText(text: 'or continue with'),
              const SizedBox(height: 16),
              SocialLoginButton(
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
