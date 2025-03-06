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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Name
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        // Control position and scaling
                        alignment: Alignment.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // const Text(
                    //   // Constants.appName,
                    //   style: TextStyle(
                    //     fontSize: 32,
                    //     fontWeight: FontWeight.bold,
                    //     fontFamily: "Poppins",
                    //     color: Color.fromARGB(255, 5, 102, 182),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 58),
              // Description
              Text(
                'Sign up or login below to manage your courses, schedules, and productivity.',
                textAlign: TextAlign.center,
                style: GoogleFonts.bitter(
                  color: const Color.fromARGB(115, 0, 0, 0),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 58),
              // Login/Signup Tabs

              Row(
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

              const SizedBox(height: 7),
              // Page View
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
              // Theme Toggle
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
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
