import 'package:flutter/material.dart';

abstract class ListViewInterface {
  Widget buildEmptyState(bool isDark);
  Widget buildLoadingState();
  Widget buildFilterChips();
  Widget buildListItems(BuildContext context);
}

abstract class GridViewInterface {
  Widget buildEmptyState(bool isDark);
  Widget buildLoadingState();
  Widget buildFilterChips();
  Widget buildGridItems(BuildContext context);
}

abstract class FilterableInterface {
  void toggleFilter(String filter);
  void clearFilters();
  void applyFilters();
  Set<String> get activeFilters;
  List<String> get availableFilters;
}
