import 'package:flutter/material.dart';
import 'package:travelowkey/widgets/destination_card.dart';
import 'package:travelowkey/widgets/destination_tab.dart';
import 'package:travelowkey/widgets/badge.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/widgets/service_button.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:travelowkey/screens/profile/user_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryBloc.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryEvent.dart';
import 'package:travelowkey/bloc/payment/payment_history/PaymentHistoryState.dart';
import 'package:travelowkey/models/paymentHistory_model.dart';
import 'package:intl/intl.dart';
import 'package:travelowkey/screens/auth/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class HomePage extends StatelessWidget {
  Future<void> saveRecommendations(
      String type, List<dynamic> recommendations) async {
    final box = Hive.box('recommendationBox');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    box.put('${type}_recommendations', recommendations);
    box.put('${type}_timestamp', currentTime);
  }

  Future<List> recommended_flights() async {
    final _storage = FlutterSecureStorage();
    final userJson = await _storage.read(key: 'user_info');
    final accessToken = userJson != null
        ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
        : null;

    // Check cache first
    final box = await Hive.openBox('recommendationBox');
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final cachedTime = box.get('flight_timestamp', defaultValue: 0);

    if (currentTime - cachedTime <= 86400000 &&
        box.get('flight_recommendations') != null) {
      return box.get('flight_recommendations');
    } else {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8800/user/verify/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer ${accessToken}",
          },
        );
        final user_id = jsonDecode(response.body)['user_id'];
        String url;
        if (user_id != null) {
          url =
              'http://10.0.2.2:8000/flights/recommendation?user_id=${user_id}';
        } else {
          url = 'http://10.0.2.2:8000/flights/recommendation';
        }
        final response2 = await http.get(
          Uri.parse(url),
        );

        final recommend_flights = jsonDecode(response2.body);
        // Cache the data
        await saveRecommendations(
            'flight', recommend_flights['recommendations']);
        return recommend_flights['recommendations'];
      } catch (e) {
        final response2 = await http.get(
          Uri.parse('http://10.0.2.2:8000/flights/recommendation'),
        );
        final recommend_flights = jsonDecode(response2.body);
        // Cache the data
        await saveRecommendations(
            'flight', recommend_flights['recommendations']);
        return recommend_flights['recommendations'];
      }
    }
  }

  Future<List> recommended_hotels() async {
    final _storage = FlutterSecureStorage();
    final userJson = await _storage.read(key: 'user_info');
    final accessToken = userJson != null
        ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
        : null;
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8800/user/verify/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${accessToken}",
        },
      );
      final user_id = jsonDecode(response.body)['user_id'];
      String url;
      if (user_id != null) {
        url = 'http://10.0.2.2:8008/hotels/recommendation?user_id=${user_id}';
      } else {
        url = 'http://10.0.2.2:8008/hotels/recommendation';
      }
      final response2 = await http.get(
        Uri.parse(url),
      );

      final recommend_hotels = jsonDecode(response2.body);
      return recommend_hotels['recommendations'];
    } catch (e) {
      final response2 = await http.get(
        Uri.parse('http://10.0.2.2:8000/hotels/recommendation'),
      );
      final recommend_hotels = jsonDecode(response2.body);
      return recommend_hotels['recommendations'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, const Color(0xFF007AFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar and Notification Icon
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Tìm kiếm...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Icon(Icons.notifications, color: Colors.white, size: 30),
                    NotificationIconButton(
                      onLoggedIn: () async {
                        final _storage = FlutterSecureStorage();
                        final userJson = await _storage.read(key: 'user_info');
                        final accessToken = userJson != null
                            ? AccountLogin.fromJson(jsonDecode(userJson))
                                .accessToken
                            : null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(
                              accessToken: accessToken!, // Pass actual token
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Priority Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BadgeWidget(icon: Icons.star, label: 'Bronze Priority'),
                    BadgeWidget(
                        icon: Icons.attach_money, label: 'Điểm tích lũy'),
                  ],
                ),
                SizedBox(height: 20),

                // Service Buttons (Flights, Hotels, etc.)
                Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ServiceButton(
                                icon: Icons.flight,
                                backgroundColor: Colors.blue,
                                label: 'Chuyến bay',
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/flight_search');
                                }),
                            ServiceButton(
                                icon: Icons.hotel,
                                backgroundColor: Colors.purple,
                                label: 'Khách sạn',
                                onTap: () {
                                  Navigator.pushNamed(context, '/hotel_search');
                                }),
                            ServiceButton(
                                icon: Icons.directions_bus,
                                backgroundColor: Colors.green,
                                label: 'Xe khách'),
                            ServiceButton(
                                icon: Icons.local_taxi,
                                backgroundColor: Colors.redAccent,
                                label: 'Taxi'),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ServiceButton(
                                icon: Icons.restaurant, label: 'Nhà hàng'),
                            ServiceButton(
                                icon: Icons.local_activity, label: 'Hoạt động'),
                            ServiceButton(
                                icon: Icons.directions_bike, label: 'Thuê xe'),
                            ServiceButton(
                                icon: Icons.local_gas_station,
                                label: 'Xăng dầu'),
                          ],
                        ),
                      ],
                    )),
                SizedBox(height: 20),
                // Favorite Destinations Section Title
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.airplane_ticket, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'Top những điểm đến được yêu thích',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Destination Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DestinationTab(label: 'TP HCM', isSelected: true),
                        DestinationTab(label: 'Hà Nội', isSelected: false),
                        DestinationTab(label: 'Đà Nẵng', isSelected: false),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Horizontal List of Destination Cards
                    SizedBox(
                        height: 200, // Adjust height as needed
                        child: FutureBuilder(
                          future: recommended_flights(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Đã xảy ra lỗi: ${snapshot.error}'));
                            } else {
                              final recommendFlights = snapshot.data ?? [];
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendFlights.length,
                                itemBuilder: (context, index) {
                                  final flight = recommendFlights[index];
                                  return DestinationCard(data: {
                                    'type': 'flight',
                                    'flight': flight,
                                  });
                                },
                              );
                            }
                          },
                        )),
                  ],
                ),
                SizedBox(height: 20),
                // Favorite Hotels Section Title
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hotel_class, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'Top những khách sạn được yêu thích',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Destination Tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DestinationTab(label: 'TP HCM', isSelected: true),
                        DestinationTab(label: 'Hà Nội', isSelected: false),
                        DestinationTab(label: 'Đà Nẵng', isSelected: false),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Horizontal List of Destination Cards
                    SizedBox(
                        height: 200, // Adjust height as needed
                        child: FutureBuilder(
                          future: recommended_hotels(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Đã xảy ra lỗi: ${snapshot.error}'));
                            } else {
                              final recommendHotels = snapshot.data ?? [];
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendHotels.length,
                                itemBuilder: (context, index) {
                                  final hotel = recommendHotels[index];
                                  return DestinationCard(data: {
                                    'type': 'hotel',
                                    'hotel': hotel,
                                  });
                                },
                              );
                            }
                          },
                        )),
                  ],
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khám phá'),
      ),
      body: Center(
        child: Text('Khám phá các điểm đến mới!'),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the PaymentHistoryBloc
    final paymentHistoryBloc = BlocProvider.of<PaymentHistoryBloc>(context);

    // Dispatch the LoadPaymentHistory event
    paymentHistoryBloc.add(LoadPaymentHistory());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        title: Text("Lịch sử thanh toán", style: TextStyle(fontSize: 20)),
      ),
      body: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
        builder: (context, state) {
          if (state is PaymentHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentHistoryLoaded) {
            return buildPaymentHistoryList(state.paymentHistory);
          } else if (state is PaymentHistoryFailure) {
            return Center(
              child: Text(
                "Vui lòng đăng nhập để xem lịch sử thanh toán!",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "Không có lịch sử thanh toán nào.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }

  /// Builds the list of payment history
  Widget buildPaymentHistoryList(List<PaymentHistory> paymentHistory) {
    return ListView.builder(
      itemCount: paymentHistory.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final payment = paymentHistory[index];
        return Card(
          elevation: 12,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            leading: payment.service == 'flight'
                ? const Icon(Icons.flight, color: Colors.blue)
                : const Icon(Icons.hotel, color: Colors.purple),
            title: Text(
              "${payment.service.toString().toUpperCase()} booking",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Phương thức thanh toán: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${payment.type.toString().toUpperCase()}"),
                  ],
                ),
                Row(
                  children: [
                    Text('Ngày tạo: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        "${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(payment.date))}"),
                  ],
                ),
                Row(
                  children: [
                    Text('Trạng thái: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "${payment.status.toString().toUpperCase()}",
                      style: TextStyle(
                        color: payment.status.toLowerCase() == 'pending'
                            ? Colors.orange
                            : payment.status == 'failed'
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${payment.amount.toStringAsFixed(0)} VND",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            onTap: () {
              // Handle tap on payment history item if needed
              Navigator.pushNamed(context, '/invoice', arguments: {
                'transactionId': payment.id,
                'service': payment.service,
              });
            },
          ),
        );
      },
    );
  }

  /// Displays payment details in a dialog
  void showPaymentDetails(BuildContext context, PaymentHistory payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chi tiết thanh toán #${payment.id}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ngày: ${payment.date}"),
            Text("Số tiền: \$${payment.amount.toStringAsFixed(2)}"),
            Text("Trạng thái: ${payment.status}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder<bool>(
      future: userProvider.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle errors
          return const Center(
            child: Text(
              'Đã xảy ra lỗi khi tải thông tin người dùng.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(userProvider, isLoggedIn, context),
                Transform.translate(
                  offset: const Offset(0, -40.0),
                  child: _buildOptions(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      UserProvider userProvider, bool isLoggedIn, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: isLoggedIn
            ? [
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
                Text(
                  userProvider.user?.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : [
                const Text(
                  'Đăng ký thành viên, hưởng nhiều ưu đãi!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 30),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to login or signup screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Đăng nhập/Đăng ký',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true, // Ensure ListView does not overflow
        children: [
          buildOptionTile(
            icon: Icons.credit_card,
            title: 'Thẻ của tôi',
            subtitle: 'Quản lý thẻ thanh toán',
            onTap: () {},
          ),
          buildOptionTile(
            icon: Icons.percent,
            title: 'Mã giảm giá',
            subtitle: 'Xem danh sách mã giảm giá',
            onTap: () {},
          ),
          buildOptionTile(
            icon: Icons.settings,
            title: 'Cài đặt',
            subtitle: 'Tuỳ chỉnh cài đặt cho tài khoản',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserProfilePage()), // Example navigation
              );
            },
          ),
          buildOptionTile(
            icon: Icons.help,
            title: 'Trung tâm hỗ trợ',
            subtitle: 'Giải đáp thắc mắc',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[700]),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap, // Add your action here
      ),
    );
  }
}
