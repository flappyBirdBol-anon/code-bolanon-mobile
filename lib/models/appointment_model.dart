class AppointmentModel {
  final int id;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final String? contextDetails;
  final String status;
  final String? gmeetLink;
  final int trainerId;

  AppointmentModel({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.contextDetails,
    required this.status,
    this.gmeetLink,
    required this.trainerId,
  });

  // Factory constructor to create from JSON/Map
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      price: json['price'],
      contextDetails: json['context'],
      status: json['status'],
      gmeetLink: json['gmeet_link'],
      trainerId: json['trainer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'price': price,
      'context': contextDetails,
      'status': status,
      'gmeet_link': gmeetLink,
      'trainer_id': trainerId,
    };
  }
}
