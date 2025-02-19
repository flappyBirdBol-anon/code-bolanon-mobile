import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/profile/profile_view.dart';
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
                  return MaterialPageRoute(
                    builder: (context) => const HomeView(),
                  );
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
                    builder: (context) => const ProfileView(),
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
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.onTabTapped,
            backgroundColor: const Color(0xFF448EE4),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black54,
            type: BottomNavigationBarType.fixed, // Added this line
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
