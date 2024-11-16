import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/flight/flight_results/FlightResultBloc.dart';
import 'package:travelowkey/bloc/flight/flight_results/FlightResultEvent.dart';
import 'package:travelowkey/bloc/flight/flight_results/FlightResultState.dart';
import 'package:travelowkey/repositories/flightResult_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlightResultScreen extends StatelessWidget {
  final String departure;
  final String destination;
  final DateTime date;
  final String seatClass;
  final int passengers;

  const FlightResultScreen({
    required this.departure,
    required this.destination,
    required this.date,
    required this.seatClass,
    required this.passengers,
  });

  @override
  Widget build(BuildContext context) {
    final searchInfo = {
      'departure': departure,
      'destination': destination,
      'date': date.toIso8601String(),
      'seatClass': seatClass,
      'passengers': passengers.toString(),
    };
    final apiUrl =
        'http://10.0.2.2:8000/flights/results?departure=${Uri.encodeComponent(searchInfo['departure']!)}&destination=${Uri.encodeComponent(searchInfo['destination']!)}&date=${Uri.encodeComponent(searchInfo['date']!.toString().substring(0, 10))}&seatClass=${Uri.encodeComponent(searchInfo['seatClass']!)}&passengers=${Uri.encodeComponent(searchInfo['passengers']!)}';

    return BlocProvider(
        create: (context) => FlightResultBloc(
            repository: FlightResultRepository(
                dataProvider: FlightResultDataProvider(
                    apiUrl: apiUrl))) // Pass the apiUrl to the data provider
          ..add(
            LoadFlightResults(
              searchInfo: searchInfo,
            ),
          ),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '$departure -> $destination ${date.toString().substring(0, 10)} - $seatClass - $passengers hành khách',
                maxLines: 2,
              ),
              actions: [
                IconButton(
                  icon:
                      Icon(Icons.notifications, color: Colors.white, size: 30),
                  onPressed: () {
                    // Navigate to notification screen
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, const Color(0xFF007AFF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(30),
                    //   bottomRight: Radius.circular(30),
                    // ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      // Sort and Filter Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.filter_list),
                            label:
                                Text("Bộ lọc", style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              // Open filter options and send event to bloc
                              String? filterOption =
                                  await showFilterDialog(context);
                              if (filterOption != null) {
                                // print(filterOption);
                                BlocProvider.of<FlightResultBloc>(context).add(
                                  ApplyFilter(filterOption, searchInfo),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.sort),
                            label: Text(
                              "Sắp xếp",
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () async {
                              // Open sort options and send event to bloc
                              String? sortOption =
                                  await showSortDialog(context);
                              if (sortOption != null) {
                                // print(sortOption);
                                BlocProvider.of<FlightResultBloc>(context).add(
                                  ApplySort(sortOption, searchInfo),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Flight Result List
                      Expanded(
                        child: BlocBuilder<FlightResultBloc, FlightResultState>(
                          builder: (context, state) {
                            if (state is FlightResultLoading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is FlightResultLoaded) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  itemCount: state.flights.length,
                                  itemBuilder: (context, index) {
                                    final flight = state.flights[index];
                                    return FlightCard(
                                        flight: flight, passengers: passengers);
                                  },
                                ),
                              );
                            } else if (state is FlightResultError) {
                              return Center(child: Text(state.message));
                            }
                            return Center(child: Text("No flights found."));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

Future<String?> showFilterDialog(BuildContext context) async {
  // List of filter options
  final filterOptions = [
    'Vietnam Airlines',
    'VietJet Air',
    'Bamboo Airways',
    'Pacific Airlines'
  ];

  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Choose a filter option'),
        children: filterOptions.map((option) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, option); // Return selected option
            },
            child: Text(option),
          );
        }).toList(),
      );
    },
  );
}

Future<String?> showSortDialog(BuildContext context) async {
  final sortOptions = [
    'price_asc',
    'price_desc',
    'time_departure_asc',
    'time_departure_desc'
  ];
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Choose a sort option'),
        children: sortOptions.map((option) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, option); // Return selected option
            },
            child: Text(option),
          );
        }).toList(),
      );
    },
  );
}

class FlightCard extends StatelessWidget {
  final Flight flight;
  final int passengers;

  const FlightCard({required this.flight, required this.passengers});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/flight_payment',
          arguments: {
            'flight': flight,
            'passengers': passengers,
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
  }
}
