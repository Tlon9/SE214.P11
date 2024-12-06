import 'package:flutter/material.dart';
import 'package:user_registration/widgets/destination_card.dart';
import 'package:user_registration/widgets/destination_tab.dart';
import 'package:user_registration/widgets/badge.dart';
import 'package:user_registration/widgets/service_button.dart';

class HomePage extends StatelessWidget {
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
                    Icon(Icons.notifications, color: Colors.white, size: 30),
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
                                  Navigator.pushNamed(
                                      context, '/hotel_search');
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          DestinationCard(),
                          DestinationCard(),
                          DestinationCard(),
                        ],
                      ),
                    ),
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          DestinationCard(),
                          DestinationCard(),
                          DestinationCard(),
                        ],
                      ),
                    ),
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
    return const Scaffold(
      body: Center(
        child: Text('Explore Page'),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('History Page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
