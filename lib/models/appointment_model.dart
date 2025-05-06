import 'package:code_bolanon/models/user_model.dart';
import 'package:intl/intl.dart';

class AppointmentModel {
  final int id;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final String? contextDetails;
  final String status;
  final String? gmeetLink;
  final int trainerId;
  final int? learnerId;
  final String? learnerName;
  final UserModel? trainer;

  AppointmentModel({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.contextDetails,
    required this.status,
    this.gmeetLink,
    required this.trainerId,
    this.learnerId,
    this.learnerName,
    required this.trainer,
  });

  // Factory constructor to create from JSON/Map
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Print debug information
    print('Creating AppointmentModel from JSON: $json');

    // Check if this is an error response rather than an appointment
    if (json.containsKey('message') &&
        json.containsKey('errors') &&
        !json.containsKey('start_at')) {
      print('Error: Trying to create AppointmentModel from error response');
      throw Exception('Cannot create appointment from error response');
    }

    // Handle nullable integer values safely
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Ensure id is properly parsed
    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else if (json['id'] is String) {
      id = int.tryParse(json['id']) ?? 0;
    }

    // Check if required fields exist
    if (!json.containsKey('start_at') ||
        !json.containsKey('end_at') ||
        !json.containsKey('status')) {
      print('Error: Missing required fields for AppointmentModel');
      throw Exception('Missing required fields for appointment');
    }

    return AppointmentModel(
      id: id,
      startAt: DateTime.parse(json['start_at']).toLocal(),
      endAt: DateTime.parse(json['end_at']).toLocal(),
      price: double.parse(json['price'].toString()), // Convert string to double
      contextDetails: json['context'],
      status: json['status'],
      gmeetLink: json['gmeet_link'],
      learnerId: parseNullableInt(json['learner_id']),
      trainerId:
          parseNullableInt(json['trainer_id']) ?? 0, // Default to 0 if null
      learnerName: json['learner_name'],
      trainer:
          json['trainer'] != null ? UserModel.fromJson(json['trainer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'id': id,
      'start_at': dateFormat.format(startAt.toUtc()),
      'end_at': dateFormat.format(endAt.toUtc()),
      'price': price,
      'context': contextDetails,
      'status': status,
      'gmeet_link': gmeetLink,
      'trainer_id': trainerId,
      'learner_id': learnerId,
      'learner_name': learnerName,
      'trainer': trainer
    };
  }
}
