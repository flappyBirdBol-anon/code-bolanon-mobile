class Transaction {
  final String id;
  final String paymentId;
  final String particulars;
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;
  final String status;
  final String userId;
  final String currency;
  final String type;

  Transaction({
    required this.id,
    required this.paymentId,
    required this.particulars,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    required this.status,
    required this.userId,
    this.currency = 'php',
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'particulars': particulars,
      'amount': amount,
      'payment_method': paymentMethod,
      'created_at': timestamp.toIso8601String(),
      'status': status,
      'user_id': userId,
      'currency': currency,
      'type': type,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['transaction_id'] ?? json['id'],
        paymentId: json['payment_id'],
        particulars: json['particulars'] ?? '',
        amount: (json['amount'] as num).toDouble() / 100, // Convert from cents
        paymentMethod: json['payment_method'],
        timestamp: DateTime.parse(json['created_at']),
        status: json['status'],
        userId: json['user_id'].toString(),
        currency: json['currency'] ?? 'usd',
        type: json['type']);
  }
}
