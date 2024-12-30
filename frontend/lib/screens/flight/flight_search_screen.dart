import 'package:flutter/material.dart';
import 'package:travelowkey/widgets/destination_card.dart';
import 'package:travelowkey/widgets/destination_tab.dart';
import 'package:travelowkey/widgets/datepicker.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/flight/flight_search/FlightSearchBloc.dart';
import 'package:travelowkey/bloc/flight/flight_search/FlightSearchEvent.dart';
import 'package:travelowkey/bloc/flight/flight_search/FlightSearchState.dart';
import 'package:travelowkey/repositories/flightSearch_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class FlightSearchScreen extends StatelessWidget {
  void _onSearchButtonPressed(BuildContext context) {
// Access the current state of the FlightSearchBloc
    final flightSearchBloc = BlocProvider.of<FlightSearchBloc>(context);
    final state = flightSearchBloc.state;

    // Check if required fields are null
    if (state is FlightSearchDataLoaded) {
      final departure = state.selectedDeparture;
      final destination = state.selectedDestination;
      final date =
          state.selectedDepartureDate; // assuming DatePickerField sets this
      final seatClass = state.selectedSeatClass;
      final passengerCount = state.selectedPassengerCount;
      if (departure == null ||
          destination == null ||
          date == null ||
          seatClass == null ||
          passengerCount == null) {
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
      } else if (departure == destination) {
        // Show a dialog if departure and destination are the same
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Lưu ý'),
              content: Text('Nơi đi và nơi đến không thể giống nhau.'),
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
        // Navigate to the flight results screen if all fields are filled
        Navigator.pushNamed(context, '/flight_result', arguments: {
          'departure': departure,
          'destination': destination,
          'date': date,
          'seatClass': seatClass,
          'passengerCount': passengerCount,
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlightSearchBloc(
          repository: FlightSearchRepository(
              dataProvider: FlightSearchDataProvider(
                  apiUrl: 'http://10.0.2.2:8000/flights/searchInfo/')))
        ..add(LoadFlightSearchData()),
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
          title: Text('Tìm chuyến bay'),
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
                  // Service Buttons (Flights, Hotels, etc.)
                  BlocBuilder<FlightSearchBloc, FlightSearchState>(
                    builder: (context, state) {
                      if (state is FlightSearchDataLoaded) {
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
                                Text("Từ"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.flight_takeoff,
                                        color: Colors.blue),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.7,
                                      child: DropdownButton<String>(
                                        underline: Container(),
                                        isExpanded: true,
                                        value: state.selectedDeparture,
                                        hint: Text("Chọn nơi đi"),
                                        items: state.departures
                                            .map((String departure) {
                                          return DropdownMenuItem<String>(
                                            value: departure,
                                            child: Text(departure),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            BlocProvider.of<FlightSearchBloc>(
                                                    context)
                                                .add(SelectDeparture(value));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),

                                // Destination Dropdown
                                Text("Đến"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.flight_land, color: Colors.blue),
                                    Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.7,
                                      child: DropdownButton<String>(
                                        underline: Container(),
                                        isExpanded: true,
                                        value: state.selectedDestination,
                                        hint: Text("Chọn nơi đến"),
                                        items: state.destinations
                                            .map((String destination) {
                                          return DropdownMenuItem<String>(
                                            value: destination,
                                            child: Text(destination),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            BlocProvider.of<FlightSearchBloc>(
                                                    context)
                                                .add(SelectDestination(value));
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),

                                Divider(),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ngày đi'),
                                    Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.7,
                                        child: DatePickerField(
                                          onChanged: (value) {
                                            BlocProvider.of<FlightSearchBloc>(
                                                    context)
                                                .add(SelectDepartureDate(
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
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Hạng ghế"),
                                          Row(children: [
                                            Icon(
                                                Icons
                                                    .airline_seat_recline_normal,
                                                color: Colors.blue),
                                            Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.3,
                                              child: DropdownButton<String>(
                                                underline: Container(),
                                                isExpanded: true,
                                                value: state.selectedSeatClass,
                                                hint: Center(
                                                    child: Text(
                                                  "Chọn hạng ghế",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                )),
                                                items: state.seatClasses
                                                    .map((String seatClass) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: seatClass,
                                                    child: Center(
                                                      child: FittedBox(
                                                        // This will resize the text if needed
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(seatClass),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    BlocProvider.of<
                                                                FlightSearchBloc>(
                                                            context)
                                                        .add(SelectSeatClass(
                                                            value));
                                                  }
                                                },
                                              ),
                                            ),
                                          ]),
                                          Divider(),
                                        ]),

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
                                                value: state
                                                    .selectedPassengerCount,
                                                hint: Center(
                                                  child: Text("Chọn số lượng",
                                                      style: TextStyle(
                                                          fontSize: 13)),
                                                ),
                                                items: state.passengerCounts
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
                                                                FlightSearchBloc>(
                                                            context)
                                                        .add(
                                                            SelectPassengerCount(
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
                      } else if (state is FlightSearchLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Center(child: Text('Error loading data.'));
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
                            future: recommended_flights(),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
