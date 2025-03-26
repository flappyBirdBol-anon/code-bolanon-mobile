import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/app/app_base_view_model.dart';
import 'package:code_bolanon/models/tech_stack_model.dart';
import 'package:code_bolanon/services/selected_stack_service.dart';
import 'package:code_bolanon/services/tech_stack_service.dart';
import 'package:code_bolanon/ui/common/utils/tech_stack_colors.dart';
import 'package:code_bolanon/ui/views/change_password/change_password_view.dart';
import 'package:code_bolanon/ui/views/edit_profile/edit_profile_view.dart';
import 'package:code_bolanon/ui/views/manage_stack/manage_stack_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends AppBaseViewModel with ReactiveServiceMixin {
  final _selectedStackService = locator<SelectedStackService>();
  final _techStackService = locator<TechStackService>();
  List<TechStackModel> _techStacks = [];
  // Changed from final to mutable
  bool isFetching = false;
  // User data getters
  String get firstName => userService.currentUser?.firstName ?? 'Example';
  String get lastName => userService.currentUser?.lastName ?? 'User';
  String get email =>
      userService.currentUser?.email ?? 'example.user@example.com';
  String get role => userService.currentUser?.role ?? 'Unknown';
  String get userImage => userService.currentUser?.profileImage ?? '';
  String get specialization => userService.currentUser?.specialization ?? '';
  String get organization => userService.currentUser?.organization ?? '';
  bool get isTrainer => role.toLowerCase() == 'trainer';

  List<TechStackModel> get allTechStacks => _techStacks;

  // This should be used for displaying selected stacks only
  List<TechStackModel> get selectedStacks {
    return _selectedStackService.selectedStacks
        .where((item) => item.stack != null)
        .map((item) => TechStackModel(
              id: item.stackId,
              tags: item.stack?.tags ?? '',
            ))
        .toList();
  }

  // This is for available tech stacks to add
  List<TechStackModel> get availableTechStacks => _techStacks;

  bool _isAlreadySelected(TechStackModel techStack) {
    return _selectedStackService.selectedStacks
        .any((selected) => selected.stackId == techStack.id);
  }

  Color getTechColor(String tech, ThemeData theme) {
    return TechStackColors.getColorForTech(tech, theme);
  }

  Future<void> showTechStackModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: const Column(
          children: [
            Expanded(child: ManageStackView()),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  Future<void> showEditProfileModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: EditProfileView(),
      ),
    );
  }

  void navigateToChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const ChangePasswordView(),
      ),
    );
  }

  ProfileViewModel() {
    listenToReactiveValues([_selectedStackService.selectedStacks]);
    _init();
    _selectedStackService.addListener(_onSelectedStacksChanged);
  }

  @override
  void dispose() {
    _selectedStackService.removeListener(_onSelectedStacksChanged);
    super.dispose();
  }

  void _onSelectedStacksChanged() {
    notifyListeners();
  }

  Future<void> _init() async {
    setBusy(true);
    try {
      isFetching = true;
      // Load both in parallel
      await Future.wait([
        _loadTechStacks(),
        _selectedStackService.fetchSelectedStacks(null),
      ]);
    } catch (e) {
      setError(e);
      debugPrint('Error initializing profile: $e');
    } finally {
      isFetching = false;
      setBusy(false);
    }
  }

  Future<void> _loadUserTechStacks() async {
    try {
      isFetching = true;
      await _selectedStackService.fetchSelectedStacks(null);
    } catch (e) {
      debugPrint('Error loading tech stacks: $e');
    } finally {
      isFetching = false;
    }
  }

  // Add a method to manually refresh tech stacks
  Future<void> refreshTechStacks() async {
    await _loadUserTechStacks();
  }

  Future<void> _loadTechStacks() async {
    _techStacks = await _techStackService.fetchTechStacks();
    notifyListeners();
  }

  Widget? _cachedProfileImage;

  Widget getProfileImageWidget({
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (_cachedProfileImage != null) return _cachedProfileImage!;

    const defaultError = Icon(Icons.person, size: 35, color: Colors.white70);

    if (userImage.isEmpty) {
      _cachedProfileImage = errorWidget ?? defaultError;
      return _cachedProfileImage!;
    }

    final imageUrl = imageService.getCourseThumbnailFromPath(userImage);

    _cachedProfileImage = imageService.loadImage(
      imageUrl: imageUrl,
      courseId: '',
      width: 60,
      height: 60,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );

    return _cachedProfileImage!;
  }
}
