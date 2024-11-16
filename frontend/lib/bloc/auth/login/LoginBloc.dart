import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:user_registration/bloc/auth/login/LoginState.dart';
import 'package:user_registration/bloc/auth/login/LoginEvent.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<SignInWithGoogle>(_handleGoogleSignIn);
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
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


  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    serverClientId: '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com', // Replace with your Google web client ID
  );

  Future<void> _handleGoogleSignIn(SignInWithGoogle event, Emitter<LoginState> emit) async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return; // User canceled the sign-in
      }

      final googleSignInAuthentication = await googleSignInAccount.authentication;
      final idToken = googleSignInAuthentication.idToken;
      final accessToken = googleSignInAuthentication.accessToken;
      if (idToken != null) {
        // Send the ID token to your Django backend for verification
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/auth/login/google'),
          body: jsonEncode({'id_token': idToken,'access_token':accessToken}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          // Successfully authenticated; navigate to the home page
          print("Login");
          emit(LoginSuccess());
        } else {
          // Handle authentication failure
          emit(LoginFailure(error: 'Invalid credentials'));
        }
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }
}
