import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:travelowkey/bloc/auth/registration/RegistrationEvent.dart';
import 'package:travelowkey/bloc/auth/registration/RegistrationState.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<SignInWithGoogle>(_handleGoogleSignIn);
  }

  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/signup'),
        body: {
          'email': event.email,
          'username': event.fullname,
          'password': event.password,
        },
      );

      if (response.statusCode == 201) {
        emit(RegistrationSuccess());
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Registration failed';
        emit(RegistrationFailure(error: errorMessage));
      }
    } catch (error) {
      emit(RegistrationFailure(error: error.toString()));
    }
  }

  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    serverClientId:
        '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com', // Replace with your Google web client ID
  );

  Future<void> _handleGoogleSignIn(
      SignInWithGoogle event, Emitter<RegistrationState> emit) async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return; // User canceled the sign-in
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final idToken = googleSignInAuthentication.idToken;
      final accessToken = googleSignInAuthentication.accessToken;
      if (idToken != null) {
        // Send the ID token to your Django backend for verification
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/auth/login/google'),
          body: jsonEncode({'id_token': idToken, 'access_token': accessToken}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          // Successfully authenticated; navigate to the home page
          print("Login");
          emit(RegistrationSuccess());
        } else {
          // Handle authentication failure
          emit(RegistrationFailure(error: 'Invalid credentials'));
        }
      }
    } catch (error) {
      emit(RegistrationFailure(error: error.toString()));
    }
  }
}
