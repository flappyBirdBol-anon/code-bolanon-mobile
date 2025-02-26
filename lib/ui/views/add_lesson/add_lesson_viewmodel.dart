import 'package:code_bolanon/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddLessonViewModel extends BaseViewModel {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final _navigationService = locator<NavigationService>();

  void saveLessonData() {
    // Implement save logic
    // Navigate back when done
    _navigationService.back();
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    super.dispose();
  }
}
