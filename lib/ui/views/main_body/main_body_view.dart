import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/views/available_courses/available_courses_view.dart';
import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/learner_appointment_home/learner_appointment_home_view.dart';
import 'package:code_bolanon/ui/views/learner_home/learner_home_view.dart';
import 'package:code_bolanon/ui/views/menu/menu_view.dart';
import 'package:code_bolanon/ui/views/trainer_appointment_home/trainer_appointment_home_view.dart';
import 'package:code_bolanon/ui/views/trainer_courses/trainer_courses_view.dart';
import 'package:code_bolanon/ui/views/trainer_home/trainer_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'main_body_viewmodel.dart';

class MainBodyView extends StackedView<MainBodyViewModel> {
  final String? role;
  const MainBodyView({Key? key, this.role}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MainBodyViewModel viewModel,
    Widget? child,
  ) {
    // Show loading indicator with a timeout using a stateful builder
    if (viewModel.isBusy) {
      return Scaffold(
        backgroundColor: const Color(0xFF448EE4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Wait a minute...',
                style: GoogleFonts.figtree(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If there's an error loading data, show error with retry button
    if (viewModel.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF448EE4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: GoogleFonts.figtree(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => viewModel.futureToRun(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF448EE4),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Even if not initialized fully, proceed after loading completes
    // to prevent getting stuck on the loading screen
    return Theme(
      data: ThemeData(
        canvasColor:
            const Color(0xFF448EE4), // This will force the background color
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          final isFirstRouteInCurrentTab = !await viewModel
              .navigatorKeys[viewModel.currentIndex].currentState!
              .maybePop();
          if (isFirstRouteInCurrentTab) {
            if (viewModel.currentIndex != 0) {
              viewModel.onTabTapped(0);
            } else {
              // Allow the app to close when back button is pressed on the homepage
              return SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
            body: IndexedStack(
              index: viewModel.currentIndex,
              children: [
                Navigator(
                    key: viewModel.navigatorKeys[0],
                    onGenerateRoute: (routeSettings) {
                      return viewModel.role == 'trainer'
                          ? MaterialPageRoute(
                              builder: (context) => const TrainerHomeView(),
                            )
                          : viewModel.role == 'learner'
                              ? MaterialPageRoute(
                                  builder: (context) => const LearnerHomeView(),
                                )
                              : MaterialPageRoute(
                                  builder: (context) => const HomeView());
                    }),
                Navigator(
                    key: viewModel.navigatorKeys[1],
                    onGenerateRoute: (routeSettings) {
                      return viewModel.role == 'trainer'
                          ? MaterialPageRoute(
                              builder: (context) => const TrainerCoursesView(),
                            )
                          : MaterialPageRoute(
                              builder: (context) =>
                                  const AvailableCoursesView(),
                            );
                    }),
                Navigator(
                  key: viewModel.navigatorKeys[2],
                  onGenerateRoute: (routeSettings) {
                    return viewModel.role == 'trainer'
                        ? MaterialPageRoute(
                            builder: (context) =>
                                const TrainerAppointmentHomeView(),
                          )
                        : MaterialPageRoute(
                            builder: (context) =>
                                const LearnerAppointmentHomeView(),
                          );
                  },
                ),
                Navigator(
                  key: viewModel.navigatorKeys[3],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) => const MenuView(),
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: viewModel.currentIndex == 0
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            color: viewModel.currentIndex == 0
                                ? Colors.white
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: viewModel.currentIndex == 1
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: viewModel.currentIndex == 1
                                ? Colors.white
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        label: 'Courses',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: viewModel.currentIndex == 2
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: viewModel.currentIndex == 2
                                ? Colors.white
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        label: 'Appointments',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: viewModel.currentIndex == 3
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: viewModel.currentIndex == 3
                                ? Colors.white
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        label: 'Menu',
                      ),
                    ],
                    currentIndex: viewModel.currentIndex,
                    onTap: viewModel.onTabTapped,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: const Color(0xFF448EE4),
                    unselectedItemColor: Colors.grey[600],
                    selectedLabelStyle: GoogleFonts.figtree(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: GoogleFonts.figtree(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                  ),
                ),
              ),
            )),
      ),
    );
  }

  @override
  MainBodyViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MainBodyViewModel();
}
