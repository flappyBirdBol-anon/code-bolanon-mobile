import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/images/png_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';

import 'onboarding_viewmodel.dart';

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, OnboardingViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: SvgPicture.asset(
                        PngImages.logo,
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        // Control position and scaling
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: viewModel.pageController,
                  itemCount: viewModel.onboardingData.length,
                  onPageChanged: viewModel.setCurrentPage,
                  itemBuilder: (context, index) {
                    final data = viewModel.onboardingData[index];
                    return _OnboardingPage(
                      title: data['title']!,
                      description: data['description']!,
                      animation: data['animation']!,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(viewModel),
              ),
              const SizedBox(height: 20),
              _buildButtons(viewModel, context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) =>
      OnboardingViewModel();

  List<Widget> _buildPageIndicator(OnboardingViewModel viewModel) {
    return List.generate(
      viewModel.onboardingData.length,
      (index) => _Indicator(isActive: index == viewModel.currentPage),
    );
  }

  Widget _buildButtons(OnboardingViewModel viewModel, BuildContext context) {
    const buttonTextStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
    );

    if (viewModel.isLastPage) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.navigateToAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: GoogleFonts.figtree(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.figtree(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: buttonTextStyle,
            ),
            child: Text(
              'Next',
              style: GoogleFonts.figtree(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: viewModel.navigateToAuth,
          child: Text(
            'Skip',
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String animation;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Lottie.asset(
              animation,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            description,
            style: GoogleFonts.figtree(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  final bool isActive;

  const _Indicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
