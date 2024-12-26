import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryEvent.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryState.dart';
import 'package:travelowkey/repositories/paymentHistory_repository.dart';

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final PaymentHistoryRepository repository;

  PaymentHistoryBloc({required this.repository})
      : super(PaymentHistoryInitial()) {
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
  }

  Future<void> _onLoadPaymentHistory(
      LoadPaymentHistory event, Emitter<PaymentHistoryState> emit) async {
    emit(PaymentHistoryLoading());
    try {
      final paymentHistory = await repository.fetchPaymentHistory();
      emit(PaymentHistoryLoaded(paymentHistory));
    } catch (e) {
      emit(PaymentHistoryFailure(e.toString()));
    }
  }
}
