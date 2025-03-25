import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'manage_stack_viewmodel.dart';

class ManageStackView extends StatelessWidget {
  const ManageStackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ManageStackViewModel>.reactive(
      viewModelBuilder: () => ManageStackViewModel(),
      builder: (context, viewModel, child) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selected Tech Stacks Section
            const Text(
              'Selected Tech Stacks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (viewModel.selectedTechStacks.isEmpty)
              const Text('No tech stacks selected'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: viewModel.selectedTechStacks.map((techStack) {
                return Chip(
                  label: Text(techStack.tags ?? ''),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => viewModel.removeTechStack(techStack),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Available Tech Stacks Section
            const Text(
              'Available Tech Stacks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: viewModel.availableTechStacks.map((techStack) {
                return ActionChip(
                  label: Text(techStack.tags ?? ''),
                  onPressed: () => viewModel.addTechStack(techStack),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
