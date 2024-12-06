import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

Future<http.Response> fetchQRCode(String transactionId) async {
  final url = Uri.parse('http://10.0.2.2:8080/payment/qr_code/$transactionId/');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load QR code: ${response.statusCode}');
  }
}

class InvoiceScreen extends StatelessWidget {
  final String transactionId;

  const InvoiceScreen({
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    String flightId = '';
    String passenger = '';
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading indicator while the future is being resolved
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // Show error message if the future throws an error
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final response = snapshot.data!;
                      if (response.statusCode == 200) {
                        // Parse and display the response
                        final transaction =
                            json.decode(utf8.decode(response.bodyBytes));
                        flightId = transaction['info'].toString().split('-')[1];
                        passenger =
                            transaction['info'].toString().split('-')[2];
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
                                      child: Text('Error: ${snapshot.error}'));
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
                                                    Text('${flight['From']}',
                                                        style: TextStyle(
                                                            fontSize: 15)),
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
                                                    Text('${flight['To']}',
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
                                                  children: [
                                                    Text('Ngày đi: ',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text('${flight['Date']}',
                                                        style: TextStyle(
                                                            fontSize: 15)),
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
                                                            fontSize: 15)),
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
                                      child:
                                          Text('Unexpected error occurred.'));
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${transaction['info']}',
                                        style: TextStyle(fontSize: 15)),
                                    SizedBox(height: 10),
                                    Text('${transaction['created_at']}',
                                        style: TextStyle(fontSize: 15)),
                                    SizedBox(height: 10),
                                    Text('${transaction['amount']}' + ' VND',
                                        style: TextStyle(fontSize: 15)),
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
                  future: fetchQRCode(transactionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // Decode the image and display it
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.memory(snapshot.data!.bodyBytes),
                      );
                    } else {
                      return Center(child: Text('Unexpected error occurred.'));
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
      ),
    );
  }
}

String formatMoney(int price) {
  final formatter = NumberFormat.simpleCurrency(locale: 'vi');
  return formatter.format(price);
}
