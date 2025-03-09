import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/ui/common/interfaces/list_view_interface.dart';

abstract class FilterableViewModel extends AppBaseViewModel
    implements FilterableInterface {
  final Set<String> _activeFilters = {};
  String _searchQuery = '';

  @override
  Set<String> get activeFilters => _activeFilters;

  String get searchQuery => _searchQuery;

  @override
  void toggleFilter(String filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      _activeFilters.add(filter);
    }
    applyFilters();
    notifyListeners();
  }

  @override
  void clearFilters() {
    _activeFilters.clear();
    applyFilters();
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    applyFilters();
    notifyListeners();
  }

  // To be implemented by child classes
  @override
  void applyFilters();
}
