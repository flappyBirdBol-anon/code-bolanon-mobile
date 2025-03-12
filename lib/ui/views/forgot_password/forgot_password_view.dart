import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_text_field.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/ui/common/widgets/password_validation_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';
import 'forgot_password_viewmodel.dart';

class ForgotPasswordView extends StackedView<ForgotPasswordViewModel> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, ForgotPasswordViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: viewModel.navigateBack,
        ),
        title: Text(
          'Reset Password',
          style: GoogleFonts.figtree(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    PngImages.forgotAnim,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.lock_reset,
                        size: 100,
                        color: AppColors.primary.withOpacity(0.7),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildStepIndicator(viewModel),
                const SizedBox(height: 30),
                _buildCurrentStepUI(viewModel, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ForgotPasswordViewModel viewModel) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color: index <= viewModel.currentStep
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepUI(
      ForgotPasswordViewModel viewModel, BuildContext context) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildEmailStep(viewModel, context);
      case 1:
        return _buildVerificationStep(viewModel, context);
      case 2:
        return _buildPasswordResetStep(viewModel, context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep(
      ForgotPasswordViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Text(
          'Forgot your password?',
          style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter your email address and we\'ll send you a verification code to reset your password.',
          style: GoogleFonts.figtree(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: viewModel.emailController,
          labelText: 'Email Address',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: viewModel.requestPasswordReset,
          isLoading: viewModel.isBusy,
          text: 'Send Reset Code',
          icon: Icons.send,
        ),
      ],
    );
  }

  Widget _buildVerificationStep(
      ForgotPasswordViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Text(
          'Check your email',
          style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a verification code to your email address. Please enter it below.',
          style: GoogleFonts.figtree(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: viewModel.codeController,
          labelText: 'Verification Code',
          prefixIcon: Icons.lock_clock,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: viewModel.verifyCode,
          isLoading: viewModel.isBusy,
          text: 'Verify Code',
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildPasswordResetStep(
      ForgotPasswordViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Text(
          'Create new password',
          style: GoogleFonts.figtree(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your new password must be different from your previous password.',
          style: GoogleFonts.figtree(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: viewModel.newPasswordController,
          labelText: 'New Password',
          prefixIcon: Icons.lock,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !viewModel.isPasswordVisible,
          onToggleVisibility: viewModel.togglePasswordVisibility,
          onChanged: (_) => viewModel.notifyListeners(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.confirmPasswordController,
          labelText: 'Confirm New Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !viewModel.isConfirmPasswordVisible,
          onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
          onChanged: (_) => viewModel.notifyListeners(),
        ),
        const SizedBox(height: 16),
        PasswordValidationList(
          hasMinLength: viewModel.newPasswordController.text.length >= 8,
          hasNumber:
              viewModel.newPasswordController.text.contains(RegExp(r'[0-9]')),
          hasUpperCase:
              viewModel.newPasswordController.text.contains(RegExp(r'[A-Z]')),
          hasLowerCase:
              viewModel.newPasswordController.text.contains(RegExp(r'[a-z]')),
          isMatch: viewModel.isConfirmPasswordValid,
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: viewModel.resetPassword,
          isLoading: viewModel.isBusy,
          text: 'Reset Password',
          icon: Icons.save,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required String text,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  ForgotPasswordViewModel viewModelBuilder(BuildContext context) =>
      ForgotPasswordViewModel();
}
