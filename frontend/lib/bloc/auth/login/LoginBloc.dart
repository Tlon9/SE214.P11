import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travelowkey/bloc/auth/login/LoginState.dart';
import 'package:travelowkey/bloc/auth/login/LoginEvent.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<SignInWithGoogle>(_handleGoogleSignIn);
  }
  final storage = FlutterSecureStorage();
  Future<void> _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      // await storage.delete(key: 'user_info');
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8800/api/token/'),
        body: {
          'email': event.email,
          'password': event.password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // bool hasToken = await storage.containsKey(key: 'email');
        // if (hasToken) {
        //   await storage.deleteAll();
        // }
        await storage.write(key: 'email', value: event.email.toString());
        // Save access and refresh tokens
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);
        String? value = await storage.read(key: "email");
        print(value.toString());
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Invalid credentials'));
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }

  Future<Map<String, String?>> getUserInfo() async {
    final email = await storage.read(key: 'email');
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');
    return {'email': email, 'access': accessToken, 'refresh': refreshToken};
  }

  Future<void> logout() async {
    await storage.deleteAll(); // Clear stored data
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
      SignInWithGoogle event, Emitter<LoginState> emit) async {
    try {
      // await storage.delete(key: 'user_info');
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
          Uri.parse('http://10.0.2.2:8800/auth/login/google'),
          body: jsonEncode({'id_token': idToken, 'access_token': accessToken}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          // Successfully authenticated; navigate to the home page
          // bool hasToken = await storage.containsKey(key: 'email');
          // if (hasToken) {
          //   await storage.deleteAll();
          // }
          final data = json.decode(response.body);
          await storage.write(key: 'email', value: data["email"].toString());
          await storage.write(key: 'access_token', value: data['access']);
          await storage.write(key: 'refresh_token', value: data['refresh']);
          String? value = await storage.read(key: "email");
          print(value.toString());
          emit(LoginSuccess());
        } else {
          final data = json.decode(response.body);
          print( data["email"].toString());
          // Handle authentication failure
          emit(LoginFailure(error: 'Invalid credentials'));
        }
      }
    } catch (error) {
      emit(LoginFailure(error: error.toString()));
    }
  }
}
