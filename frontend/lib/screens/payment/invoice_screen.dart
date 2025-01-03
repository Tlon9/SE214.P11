import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'dart:convert';

Future<http.Response> getTransaction(String transactionId) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/payment/transaction/$transactionId'),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

Future<http.Response> getFlight(String id) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/flights/getFlight?id=${id}'),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

Future<http.Response> getRoom(String id) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8008/hotels/getRoom?room_id=${id}'),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

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

String formatPrice(String price) {
  // Parse the string to an integer
  int value = int.tryParse(price) ?? 0;

  // Format the integer with a thousand separator
  return NumberFormat("#,###", "en_US").format(value).replaceAll(",", ".");
}

class InvoiceScreen extends StatelessWidget {
  final String transactionId;
  final String service;

  const InvoiceScreen({
    required this.transactionId,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    String flightId = '';
    String passenger = '';
    String roomId = '';
    String checkInDate = '';
    String checkOutDate = '';
    print(transactionId);
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
        title: Text("Thông tin hóa đơn", style: TextStyle(fontSize: 20)),
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
      body: service == 'flight'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                    children: [
                      FutureBuilder<http.Response>(
                        future: getTransaction(transactionId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show loading indicator while the future is being resolved
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            // Show error message if the future throws an error
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            final response = snapshot.data!;
                            if (response.statusCode == 200) {
                              // Parse and display the response
                              final transaction =
                                  json.decode(utf8.decode(response.bodyBytes));
                              flightId =
                                  transaction['info'].toString().split('-')[0];
                              passenger =
                                  transaction['info'].toString().split('-')[1];
                              return Column(
                                children: [
                                  FutureBuilder<http.Response>(
                                    future: getFlight(flightId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        final response = snapshot.data!;
                                        if (response.statusCode == 200) {
                                          final flight = json.decode(
                                              utf8.decode(response.bodyBytes));
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Từ: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              '${flight['From']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('Đến: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              '${flight['To']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Ngày đi: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              '${flight['Date']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('Giờ: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              '${flight['DepartureTime']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('Hạng ghế: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              '${flight['SeatClass']}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('Số lượng: ',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text('${passenger}',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Center(
                                              child: Text(
                                                  'Error: ${response.statusCode}'));
                                        }
                                      } else {
                                        return Center(
                                            child: Text(
                                                'Unexpected error occurred.'));
                                      }
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Mã giao dịch:',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Ngày thanh toán:',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          Text('Tổng tiền: ',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text('${transaction['info']}',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Text('${transaction['created_at']}',
                                              style: TextStyle(fontSize: 15)),
                                          SizedBox(height: 10),
                                          Text(
                                              formatPrice(
                                                      '${transaction['amount']}') +
                                                  ' VND',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.red)),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // Handle HTTP errors
                              return Center(
                                  child: Text('Error: ${response.statusCode}'));
                            }
                          } else {
                            return Center(child: Text('Unexpected error'));
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<http.Response>(
                        future: fetchQRCode(transactionId, service),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            // Decode the image and display it
                            return SizedBox(
                              width: 200,
                              height: 200,
                              child: Image.memory(snapshot.data!.bodyBytes),
                            );
                          } else {
                            return Center(
                                child: Text('Unexpected error occurred.'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                // SizedBox(height: 10),
                SubmitButton(
                    label: 'Trở về trang chủ',
                    onTap: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    }),
              ],
            )
          : Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                  children: [
                    FutureBuilder<http.Response>(
                      future: getTransaction(transactionId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Show loading indicator while the future is being resolved
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          // Show error message if the future throws an error
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final response = snapshot.data!;
                          if (response.statusCode == 200) {
                            // Parse and display the response
                            final transaction =
                                json.decode(utf8.decode(response.bodyBytes));
                            roomId =
                                transaction['info'].toString().split('_')[1];
                            checkInDate =
                                transaction['info'].toString().split('_')[2];
                            checkOutDate =
                                transaction['info'].toString().split('_')[3];
                            return Column(
                              children: [
                                FutureBuilder<http.Response>(
                                  future: getRoom(roomId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (snapshot.hasData) {
                                      final response = snapshot.data!;
                                      if (response.statusCode == 200) {
                                        final room = json.decode(
                                            utf8.decode(response.bodyBytes));
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Từ ngày: ',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            '${checkInDate.split('-').reversed.join('-')}',
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text('Đến ngày: ',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            '${checkOutDate.split('-').reversed.join('-')}',
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text('Tên phòng: ',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text('${room['Name']}',
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Center(
                                            child: Text(
                                                'Error: ${response.statusCode}'));
                                      }
                                    } else {
                                      return Center(
                                          child: Text(
                                              'Unexpected error occurred.'));
                                    }
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Mã giao dịch:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text('Ngày thanh toán:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text('Tổng tiền: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            '${transaction['info'].toString().split('_')[0] + transaction['info'].toString().split('_')[1]}',
                                            style: TextStyle(fontSize: 15)),
                                        SizedBox(height: 10),
                                        Text(
                                            '${transaction['created_at'].toString().substring(0, 10)}',
                                            style: TextStyle(fontSize: 15)),
                                        SizedBox(height: 10),
                                        Text(
                                            formatPrice(
                                                    '${transaction['amount']}') +
                                                ' VND',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.red)),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Handle HTTP errors
                            return Center(
                                child: Text('Error: ${response.statusCode}'));
                          }
                        } else {
                          return Center(child: Text('Unexpected error'));
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<http.Response>(
                      future: fetchQRCode(transactionId, service),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          // Decode the image and display it
                          return SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.memory(snapshot.data!.bodyBytes),
                          );
                        } else {
                          return Center(
                              child: Text('Unexpected error occurred.'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SubmitButton(
                  label: 'Trở về trang chủ',
                  onTap: () async {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }),
            ]),
    );
  }
}

String formatMoney(int price) {
  final formatter = NumberFormat.simpleCurrency(locale: 'vi');
  return formatter.format(price);
}
