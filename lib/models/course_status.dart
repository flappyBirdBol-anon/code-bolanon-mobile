import 'package:code_bolanon/models/course_model.dart';

enum CourseStatus {
  active,
  inactive,
  archived,
}

extension CourseStatusExtension on CourseModel {
  bool get isActive => status?.toLowerCase() == CourseStatus.active.name;
  bool get isInactive => status?.toLowerCase() == CourseStatus.inactive.name;
  bool get isArchived => status?.toLowerCase() == CourseStatus.archived.name;

  // Default to active if no status is set
  String? get status => _status ?? CourseStatus.active.name;
  String? get _status => this.toJson()['status'] as String?;
}
