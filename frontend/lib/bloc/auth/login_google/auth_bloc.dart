import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
import 'package:travelowkey/bloc/auth/login_google/auth_event.dart';
import 'package:travelowkey/bloc/auth/login_google/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  // clientId: '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com',  // Replace with your actual web client ID from Google Cloud Console

  // );

  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        // final account = await _googleSignIn.signIn();
        // final googleKey = await account?.authentication;
        // final googleToken = googleKey?.idToken;

        // if (googleToken != null) {
        //   // Send the token to the Django backend
        //   final response = await http.post(
        //     Uri.parse('http://localhost:8000/auth/social/google/'),
        //     body: {'access_token': googleToken},
        //   );

        //   if (response.statusCode == 200) {
        //     emit(Authenticated());
        //   } else {
        //     emit(AuthError('Failed to sign in with Google'));
        //   }
        // } else {
        //   emit(AuthError('Google Sign-In was cancelled'));
        // }
      } catch (e) {
        emit(AuthError('Error occurred during Google Sign-In: $e'));
      }
    });
  }
}
