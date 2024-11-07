// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Sign Up',
//       home: SignUpScreen(),
//     );
//   }
// }

// class SignUpScreen extends StatefulWidget {
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String email = '';
//   String fullName = '';
//   String password = '';

//   Future<void> registerUser() async {
//     try{
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8000/user/signup'), // Update with your Django server URL
//         headers: <String, String>{"Content-Type": "application/json; charset=UTF-8"},
//         body: json.encode({
//           "email": email,
//           "name": fullName,
//           "password": password,
//         }),
//       );
//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Đăng ký tài khoản thành công!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Đăng ký tài khoản không thành công')),
//         );
//       }
//     }
//     catch(error)
//     {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error.toString())),
//         );
//     }
//   }

//   bool _isHidden = true;
//   void _togglePasswordView() {
//     setState(() {
//       _isHidden = !_isHidden;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center, // Vertically center elements
//             crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center elements
//             children: <Widget>[
//               Text(
//                 'Đăng ký',
//                 style: TextStyle(
//                   fontSize: 24,               // Font size
//                   fontWeight: FontWeight.bold, // Bold text
//                   color: Colors.blue,          // Text color
//                   letterSpacing: 2.0,          // Letter spacing
//                 ),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || !value.contains('@')) {
//                     return 'Vui lòng nhập email';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     email = value;
//                   });
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Username'),
//                 validator: (value) {
//                   if (value == null || value == "") {
//                     return 'Vui lòng nhập username';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     fullName = value;
//                   });
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Mật khẩu',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isHidden ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: _togglePasswordView,
//                   ),
//                 ),
//                 obscureText: _isHidden,
//                 validator: (value) {
//                   if (value == null || value == "") {
//                     return 'Vui lòng nhập mật khẩu';
//                   }
//                   else if(value.length < 3)
//                   {
//                     return 'Mật khẩu phải có ít nhất 3 kí tự';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     password = value;
//                   });
//                 },
//               ),
//               Container(
//                 margin: const EdgeInsets.all(20.0),
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   child: Text('Đăng ký'),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       registerUser();
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange, // Background color
//                     foregroundColor: Colors.white, // Text and icon color
//                     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding inside the button
//                     textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Text style
//                     shape: RoundedRectangleBorder( // Button shape (rounded corners)
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/registration/RegistrationBloc.dart';
import 'package:travelowkey/bloc/auth/registration/RegistrationState.dart';
import 'package:travelowkey/bloc/auth/registration/RegistrationEvent.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: BlocProvider(
        create: (context) => RegistrationBloc(),
        child: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegistrationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is RegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Registration Successful!")),
              );
            }
          },
          child: BlocBuilder<RegistrationBloc, RegistrationState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: fullnameController,
                      decoration: InputDecoration(labelText: "Full Name"),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<RegistrationBloc>(context).add(
                          RegisterButtonPressed(
                            email: emailController.text,
                            fullname: fullnameController.text,
                            password: passwordController.text,
                          ),
                        );
                      },
                      child: Text("Register"),
                    ),
                    if (state is RegistrationLoading)
                      CircularProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
