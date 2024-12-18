import 'package:flutter/material.dart';
import 'package:user_registration/services/api_service.dart';
// import 'package:user_registration/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_registration/bloc/auth/user_profile/UserBloc.dart';
import 'package:user_registration/bloc/auth/user_profile/UserState.dart';
import 'package:user_registration/bloc/auth/user_profile/UserEvent.dart';
import 'package:user_registration/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:user_registration/repositories/userProfile_repository.dart';

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
          if(isLoggedIn) {
            print( userProvider.user?.email);
          }
          // isLoggedIn = false;
          else {print("error isLoggedIn");}
          final apiUrl = 'http://10.0.2.2:8000/user/?email=${userProvider.user?.email}';
          return BlocProvider(
            create: (context) => UserProfileBloc(repository: UserResultRepository(dataProvider: UserDataProvider(apiUrl: apiUrl)))..add(LoadUserProfile()),
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
                body:isLoggedIn
                  ? BlocBuilder<UserProfileBloc, UserProfileState>(
                      builder: (context, state) {
                        if (state is UserProfileLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is UserProfileLoaded) {
                          // print(state.user.email.toString());
                          return Column(
                            children: [
                              // User Header Section
                              Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Test3',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Personal Data Section
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('Tên đầy đủ', state.user.username),
                                      _buildInfoRow('Giới tính', state.user.gender),
                                      _buildInfoRow('Ngày Sinh', state.user.birthDate),
                                      _buildInfoRow('SĐT', state.user.phoneNumber),
                                      // _buildInfoRow('Địa chỉ', state.user.),
                                      _buildInfoRow('Email', state.user.email),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Thay đổi mật khẩu',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Logout Button
                              Container(
                                width: double.infinity,
                                color: Colors.blue,
                                child: TextButton(
                                  onPressed: () async {
                                    // Handle logout action
                                    // Clear the user info
                                    await userProvider.logout();
                                    
                                    // Navigate to the login screen after logging out
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),  // Replace with your login page
                                    );
                                  },
                                  child: const Text(
                                    'ĐĂNG XUẤT',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        else if (state is UserProfileFailure) {
                          return Center(child: Text(state.error));
                        } else {
                          return const Center(child: Text('Không tải được frofile'));
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black, // Black text color for labels
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black, // Black text color for values
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
