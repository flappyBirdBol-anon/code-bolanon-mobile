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
    this.contextDetails,
    required this.status,
    this.gmeetLink,
    required this.trainerId,
    this.learnerId,
    this.learnerName,
    this.trainer,
  });

  // Factory constructor to create from JSON/Map
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Print debug information
    print('Creating AppointmentModel from JSON: $json');

    try {
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
        if (value is String) {
          try {
            return int.parse(value);
          } catch (e) {
            print('Error parsing int from string: $value');
            return null;
          }
        }
        return null;
      }

      // Ensure id is properly parsed
      int id = 0;
      if (json['id'] is int) {
        id = json['id'];
      } else if (json['id'] is String) {
        try {
          id = int.parse(json['id']);
        } catch (e) {
          print('Error parsing id: ${json['id']}');
        }
      }

      // Parse trainer_id safely
      int trainerId = 0;
      if (json['trainer_id'] != null) {
        if (json['trainer_id'] is int) {
          trainerId = json['trainer_id'];
        } else if (json['trainer_id'] is String) {
          try {
            trainerId = int.parse(json['trainer_id']);
          } catch (e) {
            print('Error parsing trainer_id: ${json['trainer_id']}');
          }
        }
      }

      // Check if required fields exist
      if (!json.containsKey('start_at') ||
          !json.containsKey('end_at') ||
          !json.containsKey('status')) {
        print('Error: Missing required fields for AppointmentModel');
        throw Exception('Missing required fields for appointment');
      }

      // Parse price safely
      double price = 0.0;
      try {
        price = json['price'] != null
            ? double.parse(json['price'].toString())
            : 0.0;
      } catch (e) {
        print('Error parsing price: ${json['price']}');
      }

      // Parse dates safely
      DateTime startAt = DateTime.now();
      DateTime endAt = DateTime.now().add(const Duration(hours: 1));

      try {
        startAt = json['start_at'] != null
            ? DateTime.parse(json['start_at']).toLocal()
            : DateTime.now();

        endAt = json['end_at'] != null
            ? DateTime.parse(json['end_at']).toLocal()
            : startAt.add(const Duration(hours: 1));
      } catch (e) {
        print('Error parsing dates: $e');
      }

      // Parse trainer safely
      UserModel? trainer;
      try {
        if (json['trainer'] != null) {
          if (json['trainer'] is Map<String, dynamic>) {
            trainer = UserModel.fromJson(json['trainer']);
          } else {
            print('Trainer is not a Map: ${json['trainer'].runtimeType}');
          }
        }
      } catch (e) {
        print('Error parsing trainer: $e');
      }

      return AppointmentModel(
        id: id,
        startAt: startAt,
        endAt: endAt,
        price: price,
        contextDetails: json['context'],
        status: json['status'] ?? 'unknown',
        gmeetLink: json['gmeet_link'],
        learnerId: parseNullableInt(json['learner_id']),
        trainerId: trainerId,
        learnerName: json['learner_name'],
        trainer: trainer,
      );
    } catch (e) {
      print('Error creating AppointmentModel: $e');
      // Return a default model instead of throwing
      return AppointmentModel(
        id: 0,
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(hours: 1)),
        price: 0.0,
        contextDetails: null,
        status: 'error',
        trainerId: 0,
        trainer: null,
      );
    }
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
