import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_registration/bloc/auth/registration/RegistrationBloc.dart';
import 'package:user_registration/bloc/auth/registration/RegistrationState.dart';
import 'package:user_registration/bloc/auth/registration/RegistrationEvent.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isEmailValid = false;
  bool isUsernameValid = false;
  bool isPwValid = false;

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
                  image: AssetImage('assets/backgroundLogin_2.jpg'),
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
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Email input
                                      Text("Email", style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          hintText: "example@example.com",
                                          suffixIcon: isEmailValid
                                              ? Icon(Icons.check_circle, color: Colors.green)
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

                                      Text("Username", style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: fullnameController,
                                        keyboardType: TextInputType.name,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          suffixIcon: isUsernameValid
                                              ? Icon(Icons.check_circle, color: Colors.green)
                                              : null,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            // Basic email validation
                                            if (value.length > 0 && value.trim().isNotEmpty)
                                              {isUsernameValid = true;}
                                            else {isUsernameValid = false;}
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),

                                      // Password input
                                      Text("Mật khẩu", style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isPasswordVisible = !isPasswordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            // Basic email validation
                                            if (value.length > 0 && value.trim().isNotEmpty)
                                              {isPwValid = true;}
                                            else {isPwValid = false;}
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: isEmailValid && isUsernameValid && isPwValid ? () {
                                            BlocProvider.of<RegistrationBloc>(context).add(
                                              RegisterButtonPressed(
                                                email: emailController.text,
                                                fullname: fullnameController.text,
                                                password: passwordController.text,
                                              ),
                                            );
                                          }: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isEmailValid && isUsernameValid && isPwValid? Colors.blue: Colors.grey,
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Đăng ký"),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => context.read<RegistrationBloc>().add(SignInWithGoogle()),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFDB4437),
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
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
