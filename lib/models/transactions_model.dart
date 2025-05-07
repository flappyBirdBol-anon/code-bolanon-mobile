class Transactions {
  final int id;
  final String transactionId;
  final String amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String? mode;
  int? availabilityId;
  final int? userId;
  final String? courseId;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  Transactions({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.mode,
    this.availabilityId,
    this.userId,
    this.createdAt,
    this.courseId,
    this.updatedAt,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      id: json['id'],
      transactionId: json['transaction_id'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      mode: json['mode'],
      availabilityId: json['availability_id'],
      courseId: json['course_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'mode': mode,
      'availability_id': availabilityId,
      'course_id': courseId,
      'user_id': userId,
      'status': status,
      'transaction_id': transactionId,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Transactions copyWith({
    int? id,
    String? transactionId,
    String? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? mode,
    int? availabilityId,
    int? userId,
    String? courseId,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Transactions(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      mode: mode,
      availabilityId: availabilityId,
      courseId: courseId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
