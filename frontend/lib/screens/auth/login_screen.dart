import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/login/LoginBloc.dart';
import 'package:travelowkey/bloc/auth/login/LoginEvent.dart';
import 'package:travelowkey/bloc/auth/login/LoginState.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final AuthService _authService = AuthService();
  bool isPasswordVisible = false;
  bool isEmailValid = false;
  bool isPwValid = false;

  Future<void> fetchUserInfoAndNavigate(BuildContext context) async {
    try {
      final loginBloc = context.read<LoginBloc>(); // Access the bloc instance
      final userInfo = await loginBloc.getUserInfo(); // Fetch user info
      
      // Debug: Print user info
      // print('User Info: $userInfo');
      final user = AccountLogin.fromJson(userInfo);
      await context.read<UserProvider>().saveUser(user);
      // Navigate to the main screen
      Navigator.pushNamed(
        context,
        '/main',
        arguments: userInfo, // Pass user info to the next screen if needed
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user info: $error')),
      );
    }
  }

  Widget build(BuildContext context) {
    double topContainerHeight = 250.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container giống như AppBar hoặc header
            Container(
              height: topContainerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgroundLogin_2.jpg'),
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

            // Dịch chuyển container dưới lên trên một phần
            Transform.translate(
              offset: Offset(0, -100.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
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
                    BlocProvider(
                      create: (context) => LoginBloc(),
                      child: BlocListener<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state is LoginFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error)),
                            );
                          } else if (state is LoginSuccess) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text("Login Successful!")),
                            // );
                            // final loginBloc_ = context.read<LoginBloc>(); // Access the bloc instance
                            // final userInfo = await loginBloc_.getUserInfo(); // Fetch user info
                            // Navigator.pushNamed(
                            //   context,
                            //   '/main',
                            // );
                            fetchUserInfoAndNavigate(context);
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
                                        onChanged: (value) {
                                          setState(() {
                                            // Basic email validation
                                            if (value.length > 0 &&
                                                value.trim().isNotEmpty) {
                                              isPwValid = true;
                                            } else {
                                              isPwValid = false;
                                            }
                                          });
                                        },
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
                                          onPressed: isEmailValid && isPwValid
                                              ? () {
                                                  BlocProvider.of<LoginBloc>(
                                                          context)
                                                      .add(
                                                    LoginButtonPressed(
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          passwordController
                                                              .text,
                                                    ),
                                                  );
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isEmailValid && isPwValid
                                                    ? Colors.blue
                                                    : Colors.grey,
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
                                      SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => context
                                              .read<LoginBloc>()
                                              .add(SignInWithGoogle()),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFDB4437),
                                            foregroundColor: Colors.white,
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.g_mobiledata,
                                                size: 24.0,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Google',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16,),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:() => {
                                            Navigator.pushNamed(
                                              context,
                                              '/register',
                                            )
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:Colors.blue,
                                            foregroundColor: Colors.white,
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Đăng ký tài khoản mới"),
                                        ),
                                      ),
                                      SizedBox(height: 16,),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:() => {
                                            Navigator.pushNamed(
                                              context,
                                              '/main',
                                            )
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:Colors.blue,
                                            foregroundColor: Colors.white,
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Tiếp tục sử dụng mà không đăng nhập"),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
