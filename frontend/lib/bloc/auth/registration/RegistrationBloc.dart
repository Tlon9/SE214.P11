import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:user_registration/bloc/auth/registration/RegistrationEvent.dart';
import 'package:user_registration/bloc/auth/registration/RegistrationState.dart';
import 'dart:convert';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/signup'),
        body: {
          'email': event.email,
          'name': event.fullname,
          'password': event.password,
        },
      );

      if (response.statusCode == 201) {
        emit(RegistrationSuccess());
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Registration failed';
        emit(RegistrationFailure(error: errorMessage));
      }
    } catch (error) {
      emit(RegistrationFailure(error: error.toString()));
    }
  }
}
