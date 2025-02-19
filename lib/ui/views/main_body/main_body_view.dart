import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'main_body_viewmodel.dart';

class MainBodyView extends StackedView<MainBodyViewModel> {
  const MainBodyView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MainBodyViewModel viewModel,
    Widget? child,
  ) {
    return Theme(
      data: ThemeData(
        canvasColor:
            const Color(0xFF448EE4), // Background color for the Scaffold
      ),
      child: PopScope(
        canPop: false, // Prevents the default back button behavior
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          // Check if the current tab can pop a route
          final isFirstRouteInCurrentTab = !await viewModel
              .navigatorKeys[viewModel.currentIndex].currentState!
              .maybePop();
          if (isFirstRouteInCurrentTab) {
            if (viewModel.currentIndex != 0) {
              // Switch to the home tab if not already on it
              viewModel.onTabTapped(0);
            } else {
              // Exit the app if already on the home tab
              return SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: viewModel.currentIndex, // Display the currently selected tab
            children: [
              Navigator(
                key: viewModel.navigatorKeys[0], // Navigator for the first tab
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(
                    builder: (context) => const HomeView(),
                  );
                },
              ),
              Navigator(
                key: viewModel.navigatorKeys[1], // Navigator for the second tab
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(
                    builder: (context) => const SizedBox.shrink(),
                  );
                },
              ),
              Navigator(
                key: viewModel.navigatorKeys[2], // Navigator for the third tab
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(
                    builder: (context) => const SizedBox.shrink(),
                  );
                },
              ),
              Navigator(
                key: viewModel.navigatorKeys[3], // Navigator for the fourth tab
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(
                    builder: (context) => const MenuView(),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Consultations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Menu',
              ),
            ],
            currentIndex: viewModel.currentIndex, // Highlight the selected tab
            onTap: viewModel.onTabTapped, // Handle tab taps
            backgroundColor: const Color(0xFF448EE4),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black54,
            type:
                BottomNavigationBarType.fixed, // Ensure all items are displayed
          ),
        ),
      ),
    );
  }

  @override
  MainBodyViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MainBodyViewModel();
}
