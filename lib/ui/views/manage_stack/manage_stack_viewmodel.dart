import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/services/selected_stack_service.dart';
import 'package:code_bolanon/services/tech_stack_service.dart';
import 'package:flutter/material.dart';

import '../../../models/tech_stack.dart';
import '../../../models/tech_stack_model.dart'; // Import your existing model

class ManageStackViewModel extends AppBaseViewModel {
  final TextEditingController techStackController = TextEditingController();

  List<TechStack> _techStacks = [];
  List<TechStack> _selectedTechStacks = [];

  List<TechStack> get techStacks => _techStacks;
  List<TechStack> get selectedTechStacks => _selectedTechStacks;

  List<TechStack> get availableTechStacks => _techStacks
      .where((tech) =>
          !_selectedTechStacks.any((selected) => selected.id == tech.id))
      .toList();

  final _techStackService = locator<TechStackService>();
  final _selectedStackService = locator<SelectedStackService>();

  ManageStackViewModel() {
    initialize();
  }

  // Conversion method from TechStackModel to TechStack
  TechStack _convertModelToTechStack(TechStackModel model) {
    return TechStack(
      id: model.id,
      tags: model.tags ?? '',
      // Add other properties as needed
    );
  }

  Future<void> initialize() async {
    setBusy(true);
    try {
      // Fetch all tech stacks and convert to TechStack
      final fetchedTechStackModels = await _techStackService.fetchTechStacks();
      _techStacks =
          fetchedTechStackModels.map(_convertModelToTechStack).toList();

      // Fetch selected tech stacks
      final selectedStacksData = _selectedStackService.selectedStacks;
      _selectedTechStacks = selectedStacksData
          .where((item) => item.stack != null)
          .map((item) => TechStack(
                id: item.stackId,
                tags: item.stack?.tags ?? '',
              ))
          .toList();

      notifyListeners();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> addTechStack(TechStack techStack) async {
    setBusy(true);
    try {
      await _selectedStackService.addToSelectedStack(
        null,
        techStack.id.toString(),
      );
      await initialize();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> removeTechStack(TechStack techStack) async {
    setBusy(true);
    try {
      final selectedStack = _selectedStackService.selectedStacks
          .firstWhere((stack) => stack.stackId == techStack.id);

      await _selectedStackService
          .removeFromSelectedStack(selectedStack.id.toString());
      await initialize();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    techStackController.dispose();
    super.dispose();
  }
}
