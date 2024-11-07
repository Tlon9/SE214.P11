// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:travelowkey/register_screen.dart';
// import 'dart:convert';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isHidden = true;
//   void _togglePasswordView() {
//     setState(() {
//       _isHidden = !_isHidden;
//     });
//   }
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       const String apiUrl = 'http://10.0.2.2:8000/api/token/'; // Replace with your API endpoint
//       try {
//         final response = await http.post(
//           Uri.parse(apiUrl),
//           headers: {"Content-Type": "application/json"},
//           body: json.encode({
//             "email": _emailController.text,
//             "password": _passwordController.text,
//           }),
//         );

//         if (response.statusCode == 200) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Đăng nhập thành công!')),
//           );
//         // var data = jsonDecode(response.body);
//         // String accessToken = data['access'];
//         // String refreshToken = data['refresh'];
//         Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SignUpScreen()),
//       );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Đăng nhập thất bại')),
//           );
//         }
//       } catch (e) {
//         print('Error: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Xảy ra lỗi! Vui lòng thử lại')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   title: Text('Đăng nhập'),
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Text(
//                 'Đăng nhập',
//                 style: TextStyle(
//                   fontSize: 24,               // Font size
//                   fontWeight: FontWeight.bold, // Bold text
//                   color: Colors.blue,          // Text color
//                   letterSpacing: 2.0,          // Letter spacing
//                 ),
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập email';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Mật khẩu',
//                   prefixIcon: Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isHidden ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: _togglePasswordView,
//                   ),
//                 ),
//                 obscureText: _isHidden,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Vui lòng nhập mật khẩu';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : Container(
//                       margin: const EdgeInsets.all(10.0),
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _login,
//                         child: Text('Đăng nhập'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange, // Background color
//                           foregroundColor: Colors.white, // Text and icon color
//                           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Padding inside the button
//                           textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Text style
//                           shape: RoundedRectangleBorder( // Button shape (rounded corners)
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                   ),
//               SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   print('Forgot password');
//                 },
//                 child: Text(
//                   'Quên mật khẩu?',
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
//               SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignUpScreen()),
//                   );
//                 },
//                 child: Text(
//                   'Đăng ký tài khoản',
//                   style: TextStyle(
//                     color: Colors.blue,
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
import 'package:travelowkey/bloc/auth/login/LoginBloc.dart';
import 'package:travelowkey/bloc/auth/login/LoginEvent.dart';
import 'package:travelowkey/bloc/auth/login/LoginState.dart';
// import 'dart:io';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isEmailValid = false;
  Widget build(BuildContext context) {
    // Chiều cao của container trên
    double topContainerHeight = 250.0;

    return Scaffold(
      body: Column(
        children: [
          // Container trên giống như AppBar hoặc header
          Container(
            height: topContainerHeight, // Chiều cao cố định cho container trên
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/backgroundLogin_2.jpg'), // Thay bằng đường dẫn hình ảnh của bạn
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Đăng nhập / Đăng ký",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Dịch chuyển Container dưới lên trên một phần
          Transform.translate(
            offset: Offset(
                0, -100.0), // Điều chỉnh giá trị offset để "đè" lên phần trên
            child: Container(
              // margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(16.0),
              // height: double.infinity, // Điều chỉnh chiều cao container dưới
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0), // Bo tròn góc
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: BlocProvider(
                      create: (context) => LoginBloc(),
                      child: BlocListener<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state is LoginFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error)),
                            );
                          } else if (state is LoginSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login Successful!")),
                            );
                          }
                        },
                        child: BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Email input
                                      Text("Email",
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          hintText: "example@example.com",
                                          suffixIcon: isEmailValid
                                              ? Icon(Icons.check_circle,
                                                  color: Colors.green)
                                              : null,
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            // Basic email validation
                                            isEmailValid = RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                            ).hasMatch(value);
                                          });
                                        },
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Email của bạn đã được kết nối với tài khoản Traveloka...",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 16),
                                      // Password input
                                      Text("Mật khẩu",
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isPasswordVisible =
                                                    !isPasswordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.lock, color: Colors.grey),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Chúng tôi sẽ bảo vệ dữ liệu của bạn để ngăn ngừa rủi ro bảo mật.",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            "Quên mật khẩu?",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            BlocProvider.of<LoginBloc>(context)
                                                .add(
                                              LoginButtonPressed(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Đăng nhập"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: LayoutBuilder(
  //       builder: (context, constraints) {
  //         double topDistance = constraints.maxHeight * 0.2; // 20% of the screen height for the distance from top

  //         return Column(
  //           children: [
  //             // Top Container (acts like a custom app bar)
  //             Container(
  //               height: 100.0, // Set fixed height for top container
  //               decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                   image: AssetImage('assets/backgroundLogin_2.jpg'), // Replace with your image path
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               child: Padding(
  //                 padding: EdgeInsets.all(16.0),
  //                 child: Align(
  //                   alignment: Alignment.topLeft,
  //                   child: Text(
  //                     "Đăng nhập / Đăng ký",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 20.0,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: topDistance, // Position the body container to overlap the AppBar
  //               left: 0,
  //               right: 0,
  //               child: Container(
  //                 // padding: EdgeInsets.all(16.0),
  //                 width: MediaQuery.of(context).size.width,
  //                 height: constraints.maxHeight - topDistance,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white, // Background color of the body container
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(30.0),
  //                     topRight: Radius.circular(30.0),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black26,
  //                       blurRadius: 8.0,
  //                       offset: Offset(0, 4), // Position of the shadow
  //                     ),
  //                   ],
  //                 ),
  //                 child: BlocProvider(
  //                   create: (context) => LoginBloc(),
  //                   child: BlocListener<LoginBloc, LoginState>(
  //                     listener: (context, state) {
  //                       if (state is LoginFailure) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(content: Text(state.error)),
  //                         );
  //                       } else if (state is LoginSuccess) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(content: Text("Login Successful!")),
  //                         );
  //                       }
  //                     },
  //                     child: BlocBuilder<LoginBloc, LoginState>(
  //                       builder: (context, state) {
  //                         return Column(
  //                           children: [
  //                             Padding(
  //                               padding: EdgeInsets.all(16.0),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   // Email input
  //                                   Text("Email", style: TextStyle(fontSize: 16)),
  //                                   SizedBox(height: 8),
  //                                   TextFormField(
  //                                     controller: emailController,
  //                                     keyboardType: TextInputType.emailAddress,
  //                                     decoration: InputDecoration(
  //                                       hintText: "example@example.com",
  //                                       suffixIcon: isEmailValid
  //                                           ? Icon(Icons.check_circle, color: Colors.green)
  //                                           : null,
  //                                       border: OutlineInputBorder(),
  //                                     ),
  //                                     onChanged: (value) {
  //                                       setState(() {
  //                                         // Basic email validation
  //                                         isEmailValid = RegExp(
  //                                           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  //                                         ).hasMatch(value);
  //                                       });
  //                                     },
  //                                   ),
  //                                   SizedBox(height: 8),
  //                                   Text(
  //                                     "Email của bạn đã được kết nối với tài khoản Traveloka...",
  //                                     style: TextStyle(color: Colors.grey),
  //                                   ),
  //                                   SizedBox(height: 16),
  //                                   // Password input
  //                                   Text("Mật khẩu", style: TextStyle(fontSize: 16)),
  //                                   SizedBox(height: 8),
  //                                   TextFormField(
  //                                     controller: passwordController,
  //                                     obscureText: !isPasswordVisible,
  //                                     decoration: InputDecoration(
  //                                       border: OutlineInputBorder(),
  //                                       suffixIcon: IconButton(
  //                                         icon: Icon(
  //                                           isPasswordVisible ? Icons.visibility : Icons.visibility_off,
  //                                         ),
  //                                         onPressed: () {
  //                                           setState(() {
  //                                             isPasswordVisible = !isPasswordVisible;
  //                                           });
  //                                         },
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(height: 8),
  //                                   Row(
  //                                     children: [
  //                                       Icon(Icons.lock, color: Colors.grey),
  //                                       SizedBox(width: 8),
  //                                       Expanded(
  //                                         child: Text(
  //                                           "Chúng tôi sẽ bảo vệ dữ liệu của bạn để ngăn ngừa rủi ro bảo mật.",
  //                                           style: TextStyle(color: Colors.grey),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   SizedBox(height: 16),
  //                                   Align(
  //                                     alignment: Alignment.centerLeft,
  //                                     child: TextButton(
  //                                       onPressed: () {},
  //                                       child: Text(
  //                                         "Quên mật khẩu?",
  //                                         style: TextStyle(color: Colors.blue),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     width: double.infinity,
  //                                     child: ElevatedButton(
  //                                       onPressed: () {
  //                                         BlocProvider.of<LoginBloc>(context).add(
  //                                           LoginButtonPressed(
  //                                             email: emailController.text,
  //                                             password: passwordController.text,
  //                                           ),
  //                                         );
  //                                       },
  //                                       style: ElevatedButton.styleFrom(
  //                                         backgroundColor: Colors.blue,
  //                                         foregroundColor: Colors.white,
  //                                         minimumSize: Size(double.infinity, 50),
  //                                         shape: RoundedRectangleBorder(
  //                                           borderRadius: BorderRadius.circular(8),
  //                                         ),
  //                                       ),
  //                                       child: Text("Đăng nhập"),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //     // backgroundColor: Colors.transparent,
  //   );
  // }
}
