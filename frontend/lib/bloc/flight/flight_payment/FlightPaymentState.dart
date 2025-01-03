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
  final bool useScore;
  final int amount;

  PaymentLoaded({
    required this.availableMethods,
    required this.selectedMethod,
    required this.useScore,
    required this.amount,
  });

  @override
  List<Object?> get props =>
      [availableMethods, selectedMethod, useScore, amount];
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
