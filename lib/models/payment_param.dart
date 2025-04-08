class PaymentParam {
  final String id;
  final String title;
  final String? description;
  final double price;
  final DateTime? startAt;
  final DateTime? endAt;
  final double taxRate;
  final double discountPercentage;

  PaymentParam({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.startAt,
    this.endAt,
    this.taxRate = 0,
    this.discountPercentage = 0,
  });
}
