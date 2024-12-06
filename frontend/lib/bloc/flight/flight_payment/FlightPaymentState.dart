import 'package:equatable/equatable.dart';

enum PaymentMethod { atmCard, qrCode }

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentMethod> availableMethods;
  final PaymentMethod? selectedMethod;

  PaymentLoaded({
    required this.availableMethods,
    required this.selectedMethod,
  });

  @override
  List<Object?> get props => [availableMethods, selectedMethod];
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
