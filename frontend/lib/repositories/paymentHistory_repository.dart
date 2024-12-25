import 'package:travelowkey/models/paymentHistory_model.dart';
import 'package:travelowkey/services/api_service.dart';

class PaymentHistoryRepository {
  final PaymentDataProvider dataProvider;

  PaymentHistoryRepository({required this.dataProvider});

  Future<List<PaymentHistory>> fetchPaymentHistory() async {
    try {
      return await dataProvider.fetchPaymentHistory();
    } catch (e) {
      throw Exception("Failed to fetch payment history: $e");
    }
  }
}
