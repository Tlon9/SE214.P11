import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentEvent.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentState.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
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
          selectedMethod: PaymentMethod.atmCard));
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
      ));
    }
  }
}
