import 'package:equatable/equatable.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentState.dart';

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
