import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:user_registration/bloc/auth/login_google/auth_bloc.dart';
// import 'package:user_registration/bloc/auth/login_google/auth_event.dart';
// import 'package:user_registration/bloc/auth/login_google/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class LoginScreen_Google extends StatefulWidget {
  @override
  _GoogleSignInScreenState createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<LoginScreen_Google> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   clientId: '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com', // Replace with your Google web client ID
  // );
  static const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: scopes,
    serverClientId:
        '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com', // Replace with your Google web client ID
  );
  // final String redirectUri = 'com.example.user_registration:/oauth2redirect';
  // final String clientId = '366589839768-u3472o7paifiiot4dsjra7m1pdeddo5c.apps.googleusercontent.com';
  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return; // User canceled the sign-in
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final idToken = googleSignInAuthentication.idToken;
      final accessToken = googleSignInAuthentication.accessToken;
      print(idToken);
      if (idToken != null) {
        // Send the ID token to your Django backend for verification
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8800/auth/login/google'),
          body: jsonEncode({'id_token': idToken, 'access_token': accessToken}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          // Successfully authenticated; navigate to the home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // Handle authentication failure
          print(response.statusCode);
        }
      }
    } catch (error) {
      print("Error signing in: $error");
    }
  }

  // Future<void> _handleGoogleSignIn() async {
  //   try {
  //     final googleSignInAccount = await _googleSignIn.signIn();
  //     if (googleSignInAccount == null) {
  //       return; // User canceled the sign-in
  //     }

  //     final googleSignInAuthentication = await googleSignInAccount.authentication;
  //     final idToken = googleSignInAuthentication.idToken;
  //     final accessToken = googleSignInAuthentication.accessToken;

  //     if (idToken != null) {
  //       // Send the ID token to your Django backend for verification
  //       final response = await http.post(
  //         Uri.parse('http://127.0.0.1:8000/auth/login/google'),
  //         body: jsonEncode({'id_token': idToken,'access_token':accessToken}),
  //         headers: {'Content-Type': 'application/json'},
  //       );
  //       if (response.statusCode == 200) {
  //         // Successfully authenticated; navigate to the home page
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => HomePage()),
  //         );
  //       } else {
  //         // Handle authentication failure
  //         print(response.statusCode);
  //       }
  //     }
  //   } catch (error) {
  //     print("Error signing in: $error");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Welcome to Home Page!")),
    );
  }
}
