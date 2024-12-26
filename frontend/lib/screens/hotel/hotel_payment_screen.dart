import 'package:flutter/material.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/models/room_model.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentEvent.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentState.dart';
import 'package:travelowkey/bloc/hotel/hotel_payment/HotelPaymentBloc.dart';
import 'package:provider/provider.dart';

Future<http.Response> fetchQRCode(String transactionId, String service) async {
  final url = Uri.parse(
      'http://10.0.2.2:8080/payment/qr_code?transactionId=${transactionId}&service=${service}');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load QR code: ${response.statusCode}');
  }
}

class HotelPaymentScreen extends StatelessWidget {
  final Hotel hotel;
  final Room room;
  final int passengers;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const HotelPaymentScreen(
      {required this.hotel,
      required this.room,
      required this.passengers,
      required this.checkInDate,
      required this.checkOutDate});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> paymentInfo = {
      'service': 'hotel',
      'type': 'atm',
      'amount':
          (hotel.price as int) * (checkOutDate.difference(checkInDate)).inDays,
      'info':
          '${hotel.id_hotel}_${room.room_id}_${checkInDate.toIso8601String().substring(0, 10)}_${checkOutDate.toIso8601String().substring(0, 10)}',
      'extraData': '',
    };
    final _storage = const FlutterSecureStorage();
    return BlocProvider(
      create: (_) => PaymentBloc()..add(LoadPaymentMethods()),
      child: Scaffold(
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
              //     "${hotel.from.toString().substring(hotel.from.toString().indexOf('(') + 1, hotel.from.toString().length - 1)} - ${hotel.to.toString().substring(hotel.to.toString().indexOf('(') + 1, hotel.to.toString().length - 1)} - ${hotel.travelTime} - ${hotel.stopDirect ?? 'Bay thẳng'}",
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
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
                            Text('Nhận phòng',
                                style: TextStyle(color: Colors.grey)),
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
                            Text('Trả phòng',
                                style: TextStyle(color: Colors.grey)),
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
                        Text(room.service.toString(),
                            style: TextStyle(color: Colors.green)),
                        SizedBox(height: 8),
                        Text(room.customers.toString() + ' Người lớn / phòng'),
                      ],
                    ),
                    SizedBox(height: 16),

                    Divider(),

                    // Non-refundable and No change policies
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Không được hoàn tiền',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.edit_off, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Không đổi lịch',
                            style: TextStyle(color: Colors.grey)),
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
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is PaymentLoaded) {
                  return Container(
                    height: 150,
                    // Ensure proper constraints are applied
                    child: Column(
                      children: [
                        Text('Phương thức thanh toán:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView(
                            children: state.availableMethods.map((method) {
                              return RadioListTile<PaymentMethod>(
                                title: Text(method == PaymentMethod.atmCard
                                    ? 'ATM card payment'
                                    : 'QR code'),
                                value: method,
                                groupValue: state.selectedMethod ??
                                    PaymentMethod.atmCard,
                                onChanged: (PaymentMethod? value) {
                                  if (value != null) {
                                    context
                                        .read<PaymentBloc>()
                                        .add(SelectPaymentMethod(value));
                                    paymentInfo['type'] =
                                        value == PaymentMethod.atmCard
                                            ? 'atm'
                                            : 'qr';
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is PaymentError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                }
                return Center(child: Text('Select a payment method.'));
              },
            ),
            SubmitButton(
              label: 'Thanh toán',
              onTap: () async {
                final userJson = await _storage.read(key: 'user_info');
                if (userJson != null) {
                  final accessToken =
                      // AccountLogin.fromJson(jsonDecode(userJson!)).accessToken;
                      AccountLogin.fromJson(jsonDecode(userJson)).accessToken;

                  final response = await http.post(
                    Uri.parse('http://10.0.2.2:8080/payment/create/'),
                    body: json.encode(paymentInfo),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': "Bearer ${accessToken}",
                    },
                  );

                  if (response.statusCode == 200) {
                    final data = json.decode(utf8.decode(response.bodyBytes));
                    final transactionId = data['transaction_id'];
                    if (data['url'] != null) {
                      if (data['url'] != 'QR_code') {
                        final url = Uri.parse(data['url']);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Quét QR thanh toán"),
                            content: FutureBuilder<http.Response>(
                              future: fetchQRCode(transactionId, 'qr'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  // Decode the image and display it
                                  return SizedBox(
                                    width: 200,
                                    height: 200,
                                    child:
                                        Image.memory(snapshot.data!.bodyBytes),
                                  );
                                } else {
                                  return Center(
                                      child:
                                          Text('Unexpected error occurred.'));
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Hoàn tất"),
                              ),
                            ],
                          ),
                        );
                      }
                      int trial_count = 0;
                      // Polling for status updates
                      Timer.periodic(Duration(seconds: 5), (timer) async {
                        trial_count++;
                        final statusResponse = await http.get(
                          Uri.parse(
                              'http://10.0.2.2:8080/payment/status/$transactionId/'),
                        );
                        final statusData =
                            json.decode(utf8.decode(statusResponse.bodyBytes));
                        final status = statusData['status'];

                        if (status != 'PENDING' || trial_count > 3) {
                          timer.cancel();
                          if (status == 'SUCCESS') {
                            // Navigate to the next screen
                            Navigator.pushNamed(context, '/invoice',
                                arguments: {
                                  'transactionId': transactionId,
                                  'service': 'hotel'
                                });
                          } else {
                            // Handle failure
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Payment failed'),
                              ),
                            );
                          }
                        }
                      });
                    } else {
                      throw Exception('Failed to make payment');
                    }
                  } else {
                    throw Exception('Failed to make payment');
                  }
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
            ),
            // Add more payment details and form fields as needed
          ],
        ),
      ),
    );
  }
}

String formatMoney(int price) {
  final formatter = NumberFormat.simpleCurrency(locale: 'vi');
  return formatter.format(price);
}
