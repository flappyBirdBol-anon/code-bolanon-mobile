import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/learner_home/learner_home_view.dart';
import 'package:code_bolanon/ui/views/menu/menu_view.dart';
import 'package:code_bolanon/ui/views/trainer_home/trainer_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    if (viewModel.role == 'trainer') {
                      return MaterialPageRoute(
                        builder: (context) => const TrainerHomeView(),
                      );
                    } else if (viewModel.role == 'learner') {
                      return MaterialPageRoute(
                        builder: (context) => const LearnerHomeView(),
                      );
                    } else {
                      return MaterialPageRoute(
                        builder: (context) => const HomeView(),
                      );
                    }
                  },
                ),
                Navigator(
                  key: viewModel.navigatorKeys[1],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) => const SizedBox.shrink(),
                    );
                  },
                ),
                Navigator(
                  key: viewModel.navigatorKeys[2],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) => const SizedBox.shrink(),
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
                                      const Color(0xFF448EE4),
                                      const Color(0xFF448EE4).withOpacity(0.7),
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
                                      const Color(0xFF448EE4),
                                      const Color(0xFF448EE4).withOpacity(0.7),
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
                                      const Color(0xFF448EE4),
                                      const Color(0xFF448EE4).withOpacity(0.7),
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
                        label: 'Consultations',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: viewModel.currentIndex == 3
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF448EE4),
                                      const Color(0xFF448EE4).withOpacity(0.7),
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
                    selectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
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
