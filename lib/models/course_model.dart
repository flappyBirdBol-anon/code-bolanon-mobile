class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;

  CourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
  });
}
