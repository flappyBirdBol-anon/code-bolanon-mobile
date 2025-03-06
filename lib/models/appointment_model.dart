class AppointmentModel {
  final int id;
  final String contextDetails;
  final String status;
  final String? gmeetLink;
  final bool? isPaid;
  final int availabilityId;
  final int userId;
  final AvailabilityData? availability;

  AppointmentModel({
    required this.id,
    required this.contextDetails,
    required this.status,
    this.gmeetLink,
    this.isPaid,
    required this.availabilityId,
    required this.userId,
    this.availability,
  });

  // Factory constructor to create from JSON/Map
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      contextDetails: json['contextDetails'],
      status: json['status'],
      gmeetLink: json['gmeetLink'],
      isPaid: json['isPaid'],
      availabilityId: json['availabilityId'],
      userId: json['userId'],
      availability: json['availability'] != null
          ? AvailabilityData.fromJson(json['availability'])
          : null,
    );
  }

  // Example of mock data with included availability
  static List<AppointmentModel> getMockAppointments() {
    return [
      AppointmentModel(
        id: 1,
        contextDetails: 'Flutter Development Session',
        status: 'Confirmed',
        gmeetLink: 'https://meet.google.com/abc-defg-hij',
        availabilityId: 1,
        userId: 1,
        availability: AvailabilityData(
          startAt: '2023-12-25 09:00:00',
          endAt: '2023-12-25 10:30:00',
          price: '2500',
        ),
      ),
      AppointmentModel(
        id: 2,
        contextDetails: 'React Components Workshop',
        status: 'Pending',
        availabilityId: 2,
        userId: 2,
        availability: AvailabilityData(
          startAt: '2023-12-26 14:00:00',
          endAt: '2023-12-26 15:30:00',
          price: '2000',
        ),
      ),
    ];
  }
}

// Simple data class for availability info
class AvailabilityData {
  final String startAt;
  final String endAt;
  final String? price;

  AvailabilityData({
    required this.startAt,
    required this.endAt,
    this.price,
  });

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    return AvailabilityData(
      startAt: json['startAt'],
      endAt: json['endAt'],
      price: json['price'],
    );
  }
}
