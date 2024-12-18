import 'package:flutter/material.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/models/room_model.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:intl/intl.dart';

class HotelPaymentScreen extends StatelessWidget {
  final Hotel hotel;
  final Room room;
  final int passengers;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const HotelPaymentScreen({required this.hotel, required this.room, required this.passengers, required this.checkInDate, required this.checkOutDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${hotel.name}", style: TextStyle(fontSize: 20)),
            // Text(
            //     "${flight.from.toString().substring(flight.from.toString().indexOf('(') + 1, flight.from.toString().length - 1)} - ${flight.to.toString().substring(flight.to.toString().indexOf('(') + 1, flight.to.toString().length - 1)} - ${flight.travelTime} - ${flight.stopDirect ?? 'Bay thẳng'}",
            //     style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white, size: 30),
            onPressed: () {
              // Navigate to notification screen
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name and icon
                  Row(
                    children: [
                      Icon(Icons.hotel, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hotel.name.toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Check-in and Check-out
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nhận phòng', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 4),
                          Text(
                            checkInDate.toIso8601String().substring(0, 10),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trả phòng', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 4),
                          Text(
                            checkOutDate.toIso8601String().substring(0, 10),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Divider(),

                  // Room information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(room.service.toString(), style: TextStyle(color: Colors.green)),
                      SizedBox(height: 8),
                      Text(room.customers.toString() +' Người lớn / phòng'),
                    ],
                  ),
                  SizedBox(height: 16),

                  Divider(),

                  // Non-refundable and No change policies
                  Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Không được hoàn tiền', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.edit_off, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Không đổi lịch', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              "${formatMoney((hotel.price as int) * (checkOutDate.difference(checkInDate)).inDays)} (${(checkOutDate.difference(checkInDate)).inDays} ngày)",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          SizedBox(height: 10),
          SubmitButton(
              label: 'Thanh toán',
              onTap: () {
                // Add payment logic here
              }),
          // Add more payment details and form fields as needed
        ],
      ),
    );
  }
}

String formatMoney(int price) {
  final formatter = NumberFormat.simpleCurrency(locale: 'vi');
  return formatter.format(price);
}
