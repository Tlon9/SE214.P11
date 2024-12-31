import 'package:flutter/material.dart';
import 'package:travelowkey/bloc/auth/user_profile/PasswordBloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/PasswordEvent.dart';
import 'package:travelowkey/services/api_service.dart';
// import 'package:travelowkey/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/PasswordState.dart';
import 'package:provider/provider.dart';
import 'package:travelowkey/repositories/userProfile_repository.dart';

class PassWordChangePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder(future: userProvider.getUserInfo(), builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Handle errors
          return const Center(
            child: Text(
              'Đã xảy ra lỗi khi tải thông tin người dùng.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }
        else
        {
          bool isLoggedIn = userProvider.user != null;
          final apiUrl = 'http://10.0.2.2:8800/user/';
          return BlocProvider(
            create: (context) => ChangePasswordBloc(repository: PasswordRepository(dataProvider: PasswordDataProvider(apiUrl: apiUrl, accessToken: userProvider.user!.accessToken)))..add(LoadPassword()),
            child: Builder(
              builder: (context) => Scaffold (
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  titleTextStyle: TextStyle(
                      color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text('Thay đổi mật khẩu'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white, size: 30),
                      onPressed: () {
                        // Navigate to notification screen
                      },
                    ),
                  ],
                ),
                body: isLoggedIn
                    ? BlocBuilder<ChangePasswordBloc, PasswordState>(
                        // listener: (context, state) {
                        //   if (state is PasswordFailure) {
                        //     // Show SnackBar only in the listener to prevent re-triggering
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text(state.error),
                        //         backgroundColor: Colors.red,
                        //       ),
                        //     );
                        //   } else if (state is PasswordSuccess) {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         content: Text('Mật khẩu đã được cập nhật.'),
                        //         backgroundColor: Colors.green,
                        //       ),
                        //     );
                        //   }
                        // },
                        builder: (context, state) {
                          if (state is PasswordLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else{
                            TextEditingController oldPwController = TextEditingController(text: "");
                            TextEditingController newPwController = TextEditingController(text: "");
                            TextEditingController newPw_Controller = TextEditingController(text: "");

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Personal Data Section
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('Mật khẩu cũ', oldPwController.text, oldPwController),
                                        _buildInfoRow('Mật khẩu mới', newPwController.text, newPwController),
                                        _buildInfoRow('Nhập lại mật khẩu mới', newPw_Controller.text, newPw_Controller),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Trigger update user info event
                                            BlocProvider.of<ChangePasswordBloc>(context).add(
                                              UpdatePassword(
                                                oldPassword: oldPwController.text,
                                                newPassword: newPwController.text,
                                                onSuccess: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Mật khẩu đã được cập nhật.'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                },
                                                onFailure: (error) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(error),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                            // if (state is PasswordSuccess)
                                            // {
                                            //   ScaffoldMessenger.of(context).showSnackBar(
                                            //     const SnackBar(
                                            //       content: Text('Mật khẩu đã được cập nhật.'),
                                            //     ),
                                            //   );
                                            // }
                                            // else if (state is PasswordFailure) {
                                            //   // Show SnackBar only in the listener to prevent re-triggering
                                            //   ScaffoldMessenger.of(context).showSnackBar(
                                            //     SnackBar(
                                            //       content: Text(state.error),
                                            //       backgroundColor: Colors.red,
                                            //     ),
                                            //   );
                                            // }
                                          },
                                          child: const Text('CẬP NHẬT'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      )
                    : Center(
                        child: const Text(
                          'Bạn chưa đăng nhập.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              )
            )
          );
        }
      }
    );
  }

  Widget _buildInfoRow(String label, String value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100, // Adjust the width as needed
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black, // Black text color for labels
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis, // Handle long labels gracefully
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value), // Set the initial value
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              style: const TextStyle(
                color: Colors.black, // Black text color for the input
                fontSize: 16,
              ),
              onChanged: (newValue) {
                // Update the controller value when text changes
                controller.text = newValue;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },
            ),
          ),
          ],
      ),
    );
  }
}
