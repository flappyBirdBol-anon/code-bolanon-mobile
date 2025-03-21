import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:code_bolanon/ui/views/auth/signup/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'auth_viewmodel.dart';
import 'login/login_view.dart';

class AuthView extends StackedView<AuthViewModel> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, AuthViewModel viewModel, Widget? child) {
    // Listen to keyboard visibility
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    // Update the viewmodel with keyboard state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.isKeyboardVisible != isKeyboardVisible) {
        viewModel.setKeyboardVisibility(isKeyboardVisible);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Name - Hide when keyboard is visible
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: viewModel.isKeyboardVisible ? 70 : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: viewModel.isKeyboardVisible ? 1.0 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: SvgPicture.asset(
                            color: AppColors.primary,
                            PngImages.logo,
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            // Control position and scaling
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // Description - Hide when keyboard is visible
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: viewModel.isKeyboardVisible ? 0 : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: viewModel.isKeyboardVisible ? 0.0 : 1.0,
                  child: Column(
                    children: [
                      const SizedBox(height: 58),
                      Text(
                        'Sign up or login below to manage your courses, schedules, and productivity.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.figtree(
                          color: const Color.fromARGB(115, 0, 0, 0),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Login/Signup Tabs - Always visible, but position changes
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  bottom: viewModel.isKeyboardVisible ? 10 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TabButton(
                      title: 'Login',
                      isSelected: viewModel.currentPage == 0,
                      onTap: () => viewModel.navigateToPage(0),
                    ),
                    _TabButton(
                      title: 'Sign Up',
                      isSelected: viewModel.currentPage == 1,
                      onTap: () => viewModel.navigateToPage(1),
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 3),
              // Page View - Takes remaining space
              Expanded(
                child: PageView(
                  controller: viewModel.pageController,
                  onPageChanged: viewModel.setCurrentPage,
                  children: const [
                    LoginView(),
                    SignupView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.primary // Use our darker blue
                  : Colors.transparent,
              width: 3.0, // Thicker underline
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Text(
          title,
          style: GoogleFonts.figtree(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 17.0, // Slightly larger text
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
