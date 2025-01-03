import 'package:equatable/equatable.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentState.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentEvent {}

class SelectPaymentMethod extends PaymentEvent {
  final PaymentMethod method;

  SelectPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class ToggleUseScore extends PaymentEvent {
  final bool useScore;
  final int amount;

  ToggleUseScore(this.useScore, this.amount);

  @override
  List<Object?> get props => [useScore, amount];
}
