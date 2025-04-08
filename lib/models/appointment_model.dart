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
    return AppointmentModel(
      id: json['id'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      price: double.parse(json['price'].toString()), // Convert string to double
      contextDetails: json['context'],
      status: json['status'],
      gmeetLink: json['gmeet_link'],
      learnerId: json['learner_id'],
      trainerId: json['trainer_id'],
      learnerName: json['learner_name'],
      trainer:
          json['trainer'] != null ? UserModel.fromJson(json['trainer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'id': id,
      'start_at': dateFormat.format(startAt),
      'end_at': dateFormat.format(endAt),
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
