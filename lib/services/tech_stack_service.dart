import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:stacked/stacked.dart';

class TechStackService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();

  final ReactiveValue<List<TechStackModel>> _techStacks =
      ReactiveValue<List<TechStackModel>>([]);
  List<TechStackModel> get techStacks => _techStacks.value;

  TechStackService() {
    listenToReactiveValues([_techStacks]);
  }

  Future<List<TechStackModel>> fetchTechStacks() async {
    try {
      final response = await _apiService.get('/stack');

      if (response.statusCode == 200) {
        final List<dynamic> techStacksJson = response.data['data'];
        _techStacks.value = techStacksJson
            .map((json) => TechStackModel.fromJson(json))
            .toList();
        return _techStacks.value;
      }
      return [];
    } catch (e) {
      print('Error fetching tech stacks: $e');
      return [];
    }
  }
}
