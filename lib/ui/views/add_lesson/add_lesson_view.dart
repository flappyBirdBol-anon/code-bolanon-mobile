import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'add_lesson_viewmodel.dart';

class AddLessonView extends StackedView<AddLessonViewModel> {
  const AddLessonView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddLessonViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Lesson'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: viewModel.saveLessonData,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: viewModel.titleController,
              decoration: const InputDecoration(
                labelText: 'Lesson Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.durationController,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  @override
  AddLessonViewModel viewModelBuilder(BuildContext context) =>
      AddLessonViewModel();
}
