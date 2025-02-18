import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainBodyViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void onTabTapped(int index) {
    _currentIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        _navigationService.replaceWithMainBodyView();
        break;
      case 1:
        null;
        break;
      case 2:
        null;
        break;
      case 3:
        _navigationService.navigateTo(Routes.mainBodyView);
        break;
    }
  }
}
