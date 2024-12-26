import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/paymentHistory_model.dart';

abstract class PaymentHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentHistoryInitial extends PaymentHistoryState {}

class PaymentHistoryLoading extends PaymentHistoryState {}

class PaymentHistoryLoaded extends PaymentHistoryState {
  final List<PaymentHistory> paymentHistory;

  PaymentHistoryLoaded(this.paymentHistory);

  @override
  List<Object?> get props => [paymentHistory];
}

class PaymentHistoryFailure extends PaymentHistoryState {
  final String error;

  PaymentHistoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}
