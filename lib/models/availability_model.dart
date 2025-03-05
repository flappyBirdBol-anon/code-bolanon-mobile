class AvailabilityModel {
  final int id;
  final String startAt;
  final String endAt;
  final String? price;
  final int userId;

  AvailabilityModel({
    required this.id,
    required this.startAt,
    required this.endAt,
    this.price,
    required this.userId,
  });
}
