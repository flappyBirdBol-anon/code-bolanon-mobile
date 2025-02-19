class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profileImage;
  final String? specialization;
  final String? organization;

  UserModel(
      {this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.role,
      this.profileImage,
      this.specialization,
      this.organization});
  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        profileImage: json['profile_image'],
        specialization: json['specialization'],
        organization: json['organization']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'specialization': specialization,
      'organization': organization
    };
  }
}
