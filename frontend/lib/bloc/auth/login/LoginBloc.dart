import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:travelowkey/bloc/auth/login/LoginState.dart';
import 'package:travelowkey/bloc/auth/login/LoginEvent.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/token/'),
        body: {
          'email': event.email,
          'password': event.password,
        },
      );

      if (response.statusCode == 200) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Invalid credentials'));
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }
}
