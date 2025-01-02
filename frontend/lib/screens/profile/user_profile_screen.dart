import 'package:flutter/material.dart';
import 'package:travelowkey/screens/profile/password_change_screen.dart';
import 'package:travelowkey/services/api_service.dart';
// import 'package:travelowkey/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/UserBloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/UserState.dart';
import 'package:travelowkey/bloc/auth/user_profile/UserEvent.dart';
import 'package:travelowkey/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:travelowkey/repositories/userProfile_repository.dart';

class UserProfilePage extends StatelessWidget {
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
          String isGoogle = userProvider.user!.isGoogle;
          final apiUrl = 'http://10.0.2.2:8800/user/';
          return BlocProvider(
            create: (context) => UserProfileBloc(repository: UserResultRepository(dataProvider: UserDataProvider(apiUrl: apiUrl, accessToken: userProvider.user!.accessToken)))..add(LoadUserProfile()),
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
                  title: Text('Thông tin tài khoản'),
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
                    ? BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          if (state is UserProfileLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is UserProfileLoaded) {
                            TextEditingController usernameController = TextEditingController(text: state.user.username);
                            TextEditingController genderController = TextEditingController(text: state.user.gender);
                            TextEditingController phoneNumberController = TextEditingController(text: state.user.phoneNumber);
                            TextEditingController emailController = TextEditingController(text: state.user.email);
                            TextEditingController nationalityController = TextEditingController(text: state.user.nationality);
                            TextEditingController passportNationController = TextEditingController(text: state.user.passport_nation);
                            String selectedExpirationDate = state.user.passport_expiration;
                            String selectedDate = state.user.birthDate;

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  // User Header Section
                                  Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        const CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Personal Data Section
                                  Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('Tên đầy đủ', usernameController.text, usernameController),
                                        _buildInfoRow('Giới tính', genderController.text, genderController),
                                        _buildDatePickerRow(
                                          context,
                                          'Ngày Sinh',
                                          selectedDate,
                                          (newDate) {
                                            BlocProvider.of<UserProfileBloc>(context).add(SelectBirthDate(newDate));
                                          },
                                        ),
                                        _buildInfoRow('SĐT', phoneNumberController.text, phoneNumberController),
                                        _buildInfoRow('Email', emailController.text, emailController),
                                        _buildInfoRow('Quốc tịch', nationalityController.text, nationalityController),
                                        _buildInfoRow('Quốc gia cấp', passportNationController.text, passportNationController),
                                        _buildDatePickerRow(
                                          context,
                                          'Ngày cấp',
                                          selectedExpirationDate,
                                          (newDate) {
                                            BlocProvider.of<UserProfileBloc>(context).add(SelectExpirationDate(newDate));
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Trigger update user info event
                                            BlocProvider.of<UserProfileBloc>(context).add(
                                              UpdateUserProfile(
                                                username: usernameController.text,
                                                gender: genderController.text,
                                                birthDate: selectedDate,
                                                phoneNumber: phoneNumberController.text,
                                                email: emailController.text,
                                                nationality: nationalityController.text,
                                                passport_nation: passportNationController.text,
                                                passport_expiration: selectedExpirationDate
                                              ),
                                            );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Thông tin đã được cập nhật.'),
                                              ),
                                            );
                                          },
                                          child: const Text('CẬP NHẬT'),
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          children: [
                                            if (isGoogle == "false")
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PassWordChangePage(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Thay đổi mật khẩu',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Logout Button
                                  Container(
                                    width: double.infinity,
                                    color: Colors.blue,
                                    child: TextButton(
                                      onPressed: () async {
                                        // Handle logout action
                                        await userProvider.logout();

                                        // Navigate to the login screen after logging out
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginScreen()),
                                        );
                                      },
                                      child: const Text(
                                        'ĐĂNG XUẤT',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (state is UserProfileFailure) {
                            return Center(child: Text(state.error));
                          } else {
                            return const Center(child: Text('Không tải được profile'));
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
            width: 80, // Adjust the width as needed
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
  Widget _buildDatePickerRow(
    BuildContext context,
    String label,
    String initialDate,
    ValueChanged<String> onDateChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80, // Adjust the width as needed
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
            child: GestureDetector(
              onTap: () async {
                DateTime? initialDateParsed;

                // Try parsing the date
                try {
                  initialDateParsed = DateTime.parse(initialDate);
                } catch (e) {
                  // Handle invalid format by using the current date
                  initialDateParsed = DateTime.now();
                }

                // Show date picker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDateParsed,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  // Format the picked date and call the callback
                  String formattedDate = pickedDate.toIso8601String().split('T')[0];
                  onDateChanged(formattedDate);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  initialDate.isNotEmpty ? initialDate : 'Chọn ngày',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
