import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();

  // User Information
  String get firstName => _authService.currentUser?.firstName ?? 'John';
  String get lastName => _authService.currentUser?.lastName ?? 'Doe';
  String get email => _authService.currentUser?.email ?? 'john.doe@example.com';
  String get role => _authService.currentUser?.role ?? 'Trainer';
  String get profilePictureUrl => _authService.currentUser?.profileImage ?? '';
  List<String> get techStacks => [
        'Flutter',
        'Dart',
        'Firebase',
        'REST API',
        'Node.js',
        'React',
        'MongoDB'
      ];
  String get specialization => 'Mobile Development';
  String get organization => 'Tech Academy';

  bool get isTrainer => role.toLowerCase() == 'trainer';

  int get totalCourses => 12;
  int get totalAppointments => 12;
  // Add methods to update profile, password, and tech stacks
  void updateProfile() {
    // Implement profile update logic
  }

  void updatePassword() {
    // Implement password update logic
  }

  void manageTechStack() {
    // Implement tech stack management logic
  }
}
