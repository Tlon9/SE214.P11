import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travelowkey/bloc/explore/ExploreBloc.dart';
import 'package:travelowkey/bloc/explore/ExploreEvent.dart';
import 'package:travelowkey/bloc/explore/ExploreState.dart';
import 'package:travelowkey/models/area_model.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/hotel_model.dart';
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

String formatPrice(String price) {
  // Parse the string to an integer
  int value = int.tryParse(price) ?? 0;

  // Format the integer with a thousand separator
  return NumberFormat("#,###", "en_US").format(value).replaceAll(",", ".");
}

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

    if (currentTime - cachedTime <= 300000 &&
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
          // Delete accessToken if user verification failed
          await _storage.delete(key: 'user_info');
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
        await _storage.delete(key: 'user_info');
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
    // Check cache first
    final box = await Hive.openBox('recommendationBox');
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final cachedTime = box.get('hotel_timestamp', defaultValue: 0);

    if (currentTime - cachedTime <= 300000 &&
        box.get('hotel_recommendations') != null) {
      return box.get('hotel_recommendations');
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
        // Cache the data
        await saveRecommendations('hotel', recommend_hotels['recommendations']);
        return recommend_hotels['recommendations'];
      }
    }
  }

  Future<int> getScore() async {
    final _storage = FlutterSecureStorage();
    final userJson = await _storage.read(key: 'user_info');
    if (userJson != null) {
      final accessToken =
          AccountLogin.fromJson(jsonDecode(userJson)).accessToken;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8800/user/score/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${accessToken}",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['score'];
      } else {
        return -1;
      }
    }
    return -1; // Add a default return value
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
                    FutureBuilder<int>(
                      future: getScore(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final score = snapshot.data == -1 ? 0 : snapshot.data;
                          return BadgeWidget(
                              icon: Icons.attach_money,
                              label: 'Điểm tích lũy: $score');
                        }
                      },
                    ),
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
// }
class ExplorePage extends StatelessWidget {
  final TextEditingController search_controller = TextEditingController();

  Widget buildAreaList(List<Area> areas, BuildContext context) {
    final exploreBloc = BlocProvider.of<ExploreBloc>(context);
    return SizedBox(
      height: 200, // Set a fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: areas.length,
        itemBuilder: (context, index) {
          final area = areas[index];
          return GestureDetector(
            onTap: () {
              exploreBloc.add(FetchHotels(queryArea: area.area.toString()));
            },
            child: Card(
              margin: const EdgeInsets.only(right: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: SizedBox(
                width: 150, // Set a fixed width for each card
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        area.img.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Text Information
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.area.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            area.country.toString(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          );
        },
      ),
    );
  }

  Widget buildHotelList(List<Hotel> hotels) {
    return SizedBox(
      height: 210, // Set a fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return GestureDetector(
            onTap: () {
              final now = DateTime.now();
  
              // Format the dates (you can use any format you prefer)
              final checkInDate = now;
              final checkOutDate = now.add(Duration(days: 1));
              Navigator.pushNamed(
                context,
                '/room_result',
                arguments: {
                  'hotel': hotel as Hotel,
                  'hotel_name': hotel.name,
                  'customers': 1,
                  'checkInDate': checkInDate,
                  'checkOutDate': checkOutDate,
                },
              );
            },
            child: Card(
              margin: const EdgeInsets.only(right: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: SizedBox(
                width: 150, // Set a fixed width for each card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        hotel.img.toString(), // Replace with your image URL
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 120,
                            color:
                                Colors.grey, // Background color for the placeholder
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ), // Placeholder widget
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        hotel.name.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        hotel.area.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    // Star Rating
                    Row(
                      children: List.generate(
                        hotel.rating!.toInt(),
                        (index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          );
        },
      ),
    );
  }

  Widget buildFlightList(List<Flight> flights) {
    return SizedBox(
      height: 200, // Set a fixed height for the horizontal list
      width: double.infinity, // Set a fixed width for the
      child: ListView.builder(
        // scrollDirection: Axis.horizontal,
        itemCount: flights.length,
        itemBuilder: (context, index) {
          final flight = flights[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/flight_payment',
                arguments: {
                  'flight': flight,
                  'passengers': 1,
                },
              );
            },
            child: Card(
              color: Colors.white,
              elevation: 5,
              shadowColor: Colors.black,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flight.name ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${flight.departureTime}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "${flight.from.toString().substring(flight.from.toString().indexOf('(') + 1, flight.from.toString().length - 1)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${flight.travelTime}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SvgPicture.asset(
                              'assets/icons/Arrow_1.svg',
                              height: 10,
                              width: 10,
                            ),
                            Text(
                              "${flight.stopDirect ?? 'Bay thẳng'}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "${flight.arrivalTime}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "${flight.to.toString().substring(flight.to.toString().indexOf('(') + 1, flight.to.toString().length - 1)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Text(
                          "VND ${flight.price} /khách",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exploreBloc = BlocProvider.of<ExploreBloc>(context);

    // Dispatch the initial FetchHotels event
    exploreBloc.add(FetchHotels());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        title: Text("Khám phá", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: search_controller,
              onSubmitted: (value) {
                exploreBloc.add(FetchHotels(queryArea: value));
              },
              decoration: InputDecoration(
                prefixIcon: GestureDetector(
                  onTap: () {
                    final query = search_controller.text; // Get search input value if needed
                    exploreBloc.add(FetchHotels(queryArea: query));
                  },
                  child: Icon(Icons.search),
                ),
                hintText: 'Tìm kiếm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.text, // For general text input
              textInputAction: TextInputAction.search, // Improves user experience
            ),
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  if (state is ExploreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExploreLoaded) {
                    bool areHotelsEmpty = state.hotels.isEmpty;
                    bool areFlightsEmpty = state.flights.isEmpty;

                    return ListView(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Khám phá các địa điểm mới",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        buildAreaList(state.areas, context),
                        SizedBox(height: 18),
                        Text(
                          "Các khách sạn đang phổ biến trong tháng qua",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!areHotelsEmpty)
                          buildHotelList(state.hotels)
                        else
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                "Không có khách sạn.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 18),
                        Text(
                          "vé máy bay đến các điểm du lịch",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!areFlightsEmpty)
                          buildFlightList(state.flights)
                        else
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                "Không có chuyến bay.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  } else if (state is ExploreError) {
                    return Center(
                      child: Text(
                        "Gặp lỗi khi tải danh sách khách sạn",
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Không có khách sạn nào.",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
        backgroundColor: Color(0xFF007AFF),
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
                        fontWeight: FontWeight.bold,
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
                      formatPrice("${payment.amount.toStringAsFixed(0)}") +
                          " VND",
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
                  child: _buildOptions(context, isLoggedIn),
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

  Widget _buildOptions(BuildContext context, bool isLoggedIn) {
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
            enabled: isLoggedIn,
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
    bool enabled =
        true, // Add an `enabled` parameter with a default value of true
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon,
            color: enabled
                ? Colors.grey[700]
                : Colors.grey[400]), // Dim icon when disabled
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                enabled ? Colors.black : Colors.grey, // Dim text when disabled
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: enabled ? Colors.black54 : Colors.grey),
        ),
        trailing: Icon(Icons.chevron_right,
            color: enabled ? Colors.grey : Colors.grey[400]),
        onTap: enabled ? onTap : null, // Disable tap action when not enabled
      ),
    );
  }
}
