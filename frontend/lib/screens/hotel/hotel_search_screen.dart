import 'package:flutter/material.dart';
import 'package:travelowkey/widgets/destination_card.dart';
import 'package:travelowkey/widgets/destination_tab.dart';
import 'package:travelowkey/widgets/datepicker.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_search/HotelSearchBloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_search/HotelSearchEvent.dart';
import 'package:travelowkey/bloc/hotel/hotel_search/HotelSearchState.dart';
import 'package:travelowkey/repositories/hotelSearch_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class HotelSearchScreen extends StatelessWidget {
  void _onSearchButtonPressed(BuildContext context) {
// Access the current state of the HotelSearchBloc
    final hotelSearchBloc = BlocProvider.of<HotelSearchBloc>(context);
    final state = hotelSearchBloc.state;

    // Check if required fields are null
    if (state is HotelSearchDataLoaded) {
      final area = state.selectedArea;
      final customerCount = state.selectedCustomerCount;
      final checkInDate = state.selectedCheckInDate;
      final checkOutDate = state.selectedCheckOutDate;
      if (area == null ||
          customerCount == null ||
          checkInDate == null ||
          checkOutDate == null) {
        // Show a dialog if any field is missing
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Thiếu thông tin'),
              content: Text(
                  'Vui lòng điền đầy đủ thông tin để tìm kiếm chuyến bay.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      } else if (checkInDate == checkOutDate) {
        // Show a dialog if departure and destination are the same
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Lưu ý'),
              content: Text('Ngày nhận và trả phòng không thể giống nhau.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Đóng'),
                ),
              ],
            );
          },
        );
      } else {
        // Navigate to the Hotel results screen if all fields are filled
        Navigator.pushNamed(
            context, '/hotel_result', // replace with your actual route
            arguments: {
              'area': area,
              'checkInDate': checkInDate,
              'checkOutDate': checkOutDate,
              'customerCount': customerCount,
            });
      }
    }
  }

  Future<void> saveRecommendations(
      String type, List<dynamic> recommendations) async {
    final box = Hive.box('recommendationBox');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    box.put('${type}_recommendations', recommendations);
    box.put('${type}_timestamp', currentTime);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HotelSearchBloc(
          repository: HotelSearchRepository(
              dataProvider: HotelSearchDataProvider(
                  apiUrl: 'http://10.0.2.2:8008/hotels/searchInfo/')))
        ..add(LoadHotelSearchData()),
      child: Scaffold(
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
          title: Text('Tìm khách sạn'),
          actions: [
            NotificationIconButton(
              onLoggedIn: () async {
                final _storage = FlutterSecureStorage();
                final userJson = await _storage.read(key: 'user_info');
                final accessToken = userJson != null
                    ? AccountLogin.fromJson(jsonDecode(userJson)).accessToken
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
        body: Stack(
          children: [
            // Background Gradient
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
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Buttons (Hotels, Hotels, etc.)
                  BlocBuilder<HotelSearchBloc, HotelSearchState>(
                    builder: (context, state) {
                      if (state is HotelSearchDataLoaded) {
                        return Column(children: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Departure Dropdown
                                Text("Địa điểm"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.place, color: Colors.blue),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.7,
                                      child: DropdownButton<String>(
                                        underline: Container(),
                                        isExpanded: true,
                                        value: state.selectedArea,
                                        hint: Text("Chọn nơi ở"),
                                        items: state.areas.map((String area) {
                                          return DropdownMenuItem<String>(
                                            value: area,
                                            child: Text(area),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            BlocProvider.of<HotelSearchBloc>(
                                                    context)
                                                .add(SelectArea(value));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ngày nhận phòng'),
                                    Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.7,
                                        child: DatePickerField(
                                          onChanged: (value) {
                                            BlocProvider.of<HotelSearchBloc>(
                                                    context)
                                                .add(SelectCheckInDate(
                                              DateTime.parse(value),
                                            ));
                                          },
                                        )),
                                    Divider(),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ngày trả phòng'),
                                    Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.7,
                                        child: DatePickerField(
                                          onChanged: (value) {
                                            BlocProvider.of<HotelSearchBloc>(
                                                    context)
                                                .add(SelectCheckOutDate(
                                              DateTime.parse(value),
                                            ));
                                          },
                                        )),
                                    Divider(),
                                  ],
                                ),

                                // Seat Class Dropdown
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Passenger Count Dropdown
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Số hành khách"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.person,
                                                color: Colors.blue),
                                            Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.35,
                                              child: DropdownButton<int>(
                                                underline: Container(),
                                                isExpanded: true,
                                                value:
                                                    state.selectedCustomerCount,
                                                hint: Center(
                                                  child: Text("Chọn số lượng",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                ),
                                                items: state.customerCounts
                                                    .map((int count) {
                                                  return DropdownMenuItem<int>(
                                                    value: count,
                                                    child: Center(
                                                        child: Text(
                                                            count.toString())),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    BlocProvider.of<
                                                                HotelSearchBloc>(
                                                            context)
                                                        .add(
                                                            SelectCustomerCount(
                                                                value));
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: SubmitButton(
                                label: 'Tìm kiếm',
                                onTap: () => _onSearchButtonPressed(context)),
                          ),
                        ]);
                      } else if (state is HotelSearchLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(
                            child:
                                Text('Error loading data.' + state.toString()));
                      }
                    },
                  ),

                  SizedBox(height: 20),
                  // Favorite Destinations Section
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
                            future: recommended_hotels(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Đã xảy ra lỗi: ${snapshot.error}'));
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
