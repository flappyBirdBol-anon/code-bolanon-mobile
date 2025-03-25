import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/selected_stack_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SelectedStackService with ChangeNotifier {
  final _apiService = locator<ApiService>();

  final ReactiveValue<List<SelectedStackModel>> _selectedStacks =
      ReactiveValue<List<SelectedStackModel>>([]);
  List<SelectedStackModel> get selectedStacks => _selectedStacks.value;

  SelectedStackService();

  Future<void> fetchSelectedStacks(String? courseId) async {
    try {
      final response =
          await _apiService.get('/selected_stacks', queryParameters: {
        if (courseId != null) 'course_id': courseId,
      });

      if (response.data == null) {
        _selectedStacks.value = [];
        notifyListeners();
        return;
      }

      final data = response.data;
      if (data is List) {
        _selectedStacks.value =
            data.map((item) => SelectedStackModel.fromJson(item)).toList();
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        _selectedStacks.value = (data['data'] as List)
            .map((item) => SelectedStackModel.fromJson(item))
            .toList();
      } else {
        _selectedStacks.value = [];
      }

      notifyListeners();
    } catch (e) {
      _selectedStacks.value = [];
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> addToSelectedStack(String? courseId, String stackId) async {
    try {
      final response = await _apiService.post('/selected_stacks', data: {
        'course_id': courseId.toString(),
        'stack_id': stackId.toString(),
      });

      if (response.statusCode == 201) {
        final selectedStack =
            SelectedStackModel.fromJson(response.data['data']);
        _selectedStacks.value = [..._selectedStacks.value, selectedStack];
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to selected stacks: $e');
      return false;
    }
  }

  Future<bool> removeFromSelectedStack(String selectedStackId) async {
    try {
      final response =
          await _apiService.delete('/selected_stacks/$selectedStackId');

      if (response.statusCode == 200) {
        _selectedStacks.value = _selectedStacks.value
            .where((stack) => stack.id != selectedStackId)
            .toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from selected stack: $e');
      return false;
    }
  }
}
