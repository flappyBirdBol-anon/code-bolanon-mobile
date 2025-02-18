import 'package:code_bolanon/ui/views/home/home_view.dart';
import 'package:code_bolanon/ui/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
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
            const Color(0xFF448EE4), // This will force the background color
      ),
      child: Scaffold(
        body: IndexedStack(
          index: viewModel.currentIndex,
          children: const [
            HomeView(),
            SizedBox.shrink(),
            SizedBox.shrink(),
            ProfileView(),
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
    );
  }

  @override
  MainBodyViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MainBodyViewModel();
}
