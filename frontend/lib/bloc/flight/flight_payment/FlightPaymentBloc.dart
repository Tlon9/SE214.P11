import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentEvent.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentState.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ToggleUseScore>(_onToggleUseScore);
  }

  Future<void> _onLoadPaymentMethods(
      LoadPaymentMethods event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      // Simulate a delay for loading
      print('Loading payment methods...');
      await Future.delayed(Duration(seconds: 1));

      // Emit the loaded state with available methods
      emit(PaymentLoaded(
          availableMethods: PaymentMethod.values,
          selectedMethod: PaymentMethod.atmCard,
          useScore: false,
          amount: 0));
    } catch (e) {
      print('Error loading payment methods: $e');
      emit(PaymentError('Failed to load payment methods'));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<PaymentState> emit) {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      emit(PaymentLoaded(
        availableMethods: currentState.availableMethods,
        selectedMethod: event.method,
        useScore: currentState.useScore,
        amount: currentState.amount,
      ));
    }
  }

  void _onToggleUseScore(ToggleUseScore event, Emitter<PaymentState> emit) {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      // final updatedAmount = event.useScore ? event.amount : currentState.amount;

      emit(PaymentLoaded(
        availableMethods: currentState.availableMethods,
        selectedMethod: currentState.selectedMethod,
        useScore: event.useScore,
        amount: event.amount,
      ));
    }
  }
}
