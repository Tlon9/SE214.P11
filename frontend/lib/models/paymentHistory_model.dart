class PaymentHistory {
  final String id;
  final String date;
  final double amount;
  final String status;
  final String service;
  final String type;

  PaymentHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.service,
    required this.type,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id'],
      date: json['created_at'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      service: json['service'],
      type: json['type'],
    );
  }
}
