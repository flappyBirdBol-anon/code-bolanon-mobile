class CourseParam {
  final String id;
  final String title;
  final String description;
  final double price;
  final double taxRate;
  final double discountPercentage;

  CourseParam({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.taxRate = 0.05, // 5% tax by default
    this.discountPercentage = 0.0,
  });
}
