import 'package:flutter/material.dart';

class Lesson {
  final int id;
  final int courseId;
  final String label;
  final String description;
  final String duration;
  final String? filePath;
  final String? fileName;
  String? fileType;
  final String? fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.label,
    required this.description,
    required this.duration,
    this.filePath,
    this.fileName,
    this.fileType,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Debug print of the raw json for the is_completed field
    print(
        "Lesson JSON: id=${json['id']}, is_completed=${json['is_completed']} (${json['is_completed']?.runtimeType})");

    // Properly parse isCompleted with explicit logic
    bool parsedIsCompleted = false;
    if (json.containsKey('is_completed') && json['is_completed'] != null) {
      if (json['is_completed'] is bool) {
        parsedIsCompleted = json['is_completed'];
      } else if (json['is_completed'] is int) {
        parsedIsCompleted = json['is_completed'] == 1;
      } else if (json['is_completed'] is String) {
        parsedIsCompleted = json['is_completed'].toLowerCase() == 'true' ||
            json['is_completed'] == '1';
      }
    }

    return Lesson(
      id: json['id'],
      courseId: json['course_id'] is int
          ? json['course_id']
          : int.tryParse(json['course_id']?.toString() ?? '0') ?? 0,
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      fileName: json['file'],
      fileType: json['file_type'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isCompleted: parsedIsCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId.toString(),
      'label': label,
      'description': description,
      'duration': duration,
      'file_name': fileName,
      'file_type': fileType,
      'file_url': fileUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  Lesson copyWith({
    int? id,
    String? label,
    int? courseId,
    String? description,
    String? duration,
    String? fileUrl,
    String? fileName,
    String? fileType,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      label: label ?? this.label,
      courseId: courseId ?? this.courseId,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Helper method to get file icon based on file type
  IconData getFileIcon() {
    if (fileType == null) return Icons.insert_drive_file;

    if (fileType!.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType!.contains('word') || fileType!.contains('docx'))
      return Icons.description;
    if (fileType!.contains('excel') || fileType!.contains('xlsx'))
      return Icons.table_chart;
    if (fileType!.contains('text') || fileType!.contains('txt'))
      return Icons.text_snippet;
    if (fileType!.contains('video')) return Icons.video_file;
    if (fileType!.contains('powerpoint') || fileType!.contains('pptx'))
      return Icons.slideshow;

    return Icons.insert_drive_file;
  }
}
