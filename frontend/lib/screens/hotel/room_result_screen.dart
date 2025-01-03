import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travelowkey/bloc/hotel/room_results/RoomResultBloc.dart';
import 'package:travelowkey/bloc/hotel/room_results/RoomResultEvent.dart';
import 'package:travelowkey/bloc/hotel/room_results/RoomResultState.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/repositories/roomResult_repository.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:travelowkey/models/room_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'dart:convert';

class RoomResultScreen extends StatelessWidget {
  final Hotel hotel;
  final String hotel_name;
  final int customers;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const RoomResultScreen(
      {required this.hotel,
      required this.hotel_name,
      required this.customers,
      required this.checkInDate,
      required this.checkOutDate});

  @override
  Widget build(BuildContext context) {
    final searchInfo = {
      'hotel_id': hotel.id_hotel.toString(),
      'hotel_name': hotel_name,
      'customers': customers.toString(),
    };
    final apiUrl =
        'http://10.0.2.2:8008/hotels/results_room?Hotel_id=${Uri.encodeComponent(searchInfo['hotel_id']!)}&checkInDate=${Uri.encodeComponent(checkInDate.toString().substring(0, 10))}&checkOutDate=${Uri.encodeComponent(checkOutDate.toString().substring(0, 10))}';

    return BlocProvider(
        create: (context) => RoomResultBloc(
            repository: RoomResultRepository(
                dataProvider: RoomResultDataProvider(
                    apiUrl: apiUrl))) // Pass the apiUrl to the data provider
          ..add(
            LoadRoomResults(
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
                '$hotel_name',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              actions: [
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
                              final filterOption =
                                  await showFilterDialog(context);
                              if (filterOption != null) {
                                // print(filterOption);
                                BlocProvider.of<RoomResultBloc>(context).add(
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
                                BlocProvider.of<RoomResultBloc>(context).add(
                                  ApplySort(sortOption, searchInfo),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Room Result List
                      Expanded(
                        child: BlocBuilder<RoomResultBloc, RoomResultState>(
                          builder: (context, state) {
                            if (state is RoomResultLoading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is RoomResultLoaded) {
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
                                  itemCount: state.rooms.length,
                                  itemBuilder: (context, index) {
                                    final room = state.rooms[index];
                                    return RoomCard(
                                        hotel: hotel,
                                        room: room,
                                        customers: customers,
                                        checkInDate: checkInDate,
                                        checkOutDate: checkOutDate);
                                  },
                                ),
                              );
                            } else if (state is RoomResultError) {
                              // return Center(child: Text(state.message));
                              return Center(child: Text(state.message));
                            }
                            return Center(child: Text("No Rooms found."));
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

Future<Map<String, dynamic>?> showFilterDialog(BuildContext context) async {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Filter Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),

                // Min and Max Price Inputs in Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                          prefixText: 'VND ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('-', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                          prefixText: 'VND ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Validate price input
                        String? minPrice = minPriceController.text.trim();
                        String? maxPrice = maxPriceController.text.trim();
                        if (minPrice.isEmpty || maxPrice.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please enter both minimum and maximum prices'),
                            ),
                          );
                          return;
                        }
                        int min = int.tryParse(minPrice) ?? 0;
                        int max = int.tryParse(maxPrice) ?? 0;
                        if (max < min) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Maximum price must be greater than or equal to minimum price'),
                            ),
                          );
                          return;
                        }

                        // Pass selected filters
                        Navigator.pop(context, {
                          'minPrice': minPrice,
                          'maxPrice': maxPrice,
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<String?> showSortDialog(BuildContext context) async {
  final sortOptions = [
    'price_asc',
    'price_desc',
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

final formatter = NumberFormat.simpleCurrency(locale: 'vi');

class RoomCard extends StatelessWidget {
  final Hotel hotel;
  final Room room;
  final int customers;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const RoomCard(
      {required this.hotel,
      required this.room,
      required this.customers,
      required this.checkInDate,
      required this.checkOutDate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 150, // Fixed height for the image
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: PageView.builder(
              itemCount: room.img!.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    room.img![index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      // Wrap the Text in an Expanded to constrain it
                      child: Text(
                        "${room.name.toString()}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2, // Limit to 2 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      child: Text(
                        room.service.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                        maxLines: null, // Allow unlimited lines
                        overflow: TextOverflow
                            .visible, // Ensure text overflows are visible
                      ),
                    ),
                    // Room Services
                    // const SizedBox(height: 12),
                    const Spacer(),
                    Icon(Icons.person, color: Colors.blue),
                    Text(
                      '${room.customers} khách/ phòng',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Empty space to align price on the right
                    Text(
                      '${formatter.format(room.price)}/phòng/đêm',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // "Chọn" Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      Navigator.pushNamed(
                        context,
                        '/hotel_payment',
                        arguments: {
                          'room': room,
                          "hotel": hotel,
                          'passengers': customers,
                          'checkInDate': checkInDate,
                          'checkOutDate': checkOutDate
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: const Color(0xFFEB3811),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Chọn',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
