class CourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final int lessons;

  CourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.lessons,
  });
}
