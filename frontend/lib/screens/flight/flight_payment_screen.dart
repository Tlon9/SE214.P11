import 'package:flutter/material.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/accountLogin_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelowkey/widgets/submit_button.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentEvent.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentState.dart';
import 'package:travelowkey/bloc/flight/flight_payment/FlightPaymentBloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:travelowkey/widgets/notification_button.dart';
import 'package:travelowkey/screens/home/notification_screen.dart';

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

class PaymentScreen extends StatelessWidget {
  final Flight flight;
  final int passengers;

  const PaymentScreen({required this.flight, required this.passengers});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> services = {
      'VietJet Air': [
        '7kg hành lý xách tay',
        'Wifi không có sẵn',
        'Dịch vụ ăn uống',
        'Airbus A350'
      ],
      'Vietnam Airlines': [
        '7kg hành lý xách tay',
        'Wifi không có sẵn',
        'Dịch vụ ăn uống',
        'Boeing 787-10'
      ],
      'Bamboo Airways': [
        '7kg hành lý xách tay',
        'Wifi không có sẵn',
        'Dịch vụ ăn uống',
        'Boeing 787-9 Dreamliner'
      ],
      'Pacific Airlines': [
        '7kg hành lý xách tay',
        'Wifi không có sẵn',
        'Dịch vụ ăn uống',
        'Airbus A320'
      ],
      'Vietravel Airlines': [
        '7kg hành lý xách tay',
        'Wifi không có sẵn',
        'Dịch vụ ăn uống',
        'Airbus A320'
      ],
    };
    final Map<String, dynamic> paymentInfo = {
      'service': 'flight',
      'type': 'atm',
      'amount': (flight.price ?? 0) * (passengers ?? 0),
      'info': '${flight.flightId}-${passengers}',
      'extraData': '',
    };
    bool useScore = false;
    final _storage = const FlutterSecureStorage();

    Future<int> getScore() async {
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
              Text("${flight.name}", style: TextStyle(fontSize: 20)),
              Text(
                  "${flight.from.toString().substring(flight.from.toString().indexOf('(') + 1, flight.from.toString().length - 1)} - ${flight.to.toString().substring(flight.to.toString().indexOf('(') + 1, flight.to.toString().length - 1)} - ${flight.travelTime} - ${flight.stopDirect ?? 'Bay thẳng'}",
                  style: TextStyle(fontSize: 12)),
            ],
          ),
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: const Color.fromARGB(255, 246, 234, 234),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${flight.from}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/icons/Arrow_1.svg',
                            height: 10,
                            width: 10,
                          ),
                          SizedBox(width: 10),
                          Text("${flight.to}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.access_time_outlined),
                          SizedBox(width: 10),
                          Text("${flight.travelTime}",
                              style: TextStyle(fontSize: 15)),
                        ],
                      )
                    ]),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 300, // Ensures the Column takes up the full height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${flight.departureTime}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("${flight.arrivalTime}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  child: VerticalDivider(
                    color: Colors.blue,
                    thickness: 2.0,
                    width: 20,
                  ),
                ),
                SizedBox(
                  height: 300, // Ensures the Column takes up the full height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${flight.from}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Card(
                        color: const Color.fromARGB(255, 246, 234, 234),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200,
                            width: 250,
                            child: services[flight.name] != null
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Thông tin chi tiết chuyến bay',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      ...services[flight.name]
                                          .map<Widget>((service) => Text(
                                              ' - ' + service,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15)))
                                          .toList()
                                    ],
                                  )
                                : Text('Không có dịch vụ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Text("${flight.to}",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Text(
            //     "${formatMoney(paymentInfo['amount'] as int)} ($passengers vé)",
            //     style: const TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.red)),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoaded) {
                  return Text(
                    "${formatMoney(state.amount == 0 ? paymentInfo['amount'] : state.amount)} ($passengers vé)",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  );
                }
                return SizedBox.shrink(); // Or a placeholder
              },
            ),
            SizedBox(height: 10),
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is PaymentLoaded) {
                  return Container(
                    height: 150,
                    margin: EdgeInsets.only(top: 20, left: 20),
                    child: Column(
                      children: [
                        Text('Phương thức thanh toán:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
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
            // SizedBox(height: 10),
            //Add a checkbox for use score to pay
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoaded) {
                      return Row(
                        children: [
                          FutureBuilder<int>(
                            future:
                                getScore(), // Replace with actual access token
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData ||
                                  snapshot.data == -1) {
                                return SizedBox.shrink();
                              } else {
                                return Container(
                                  margin: EdgeInsets.only(left: 30),
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: state.useScore,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            if (value) {
                                              paymentInfo['amount'] =
                                                  (flight.price ?? 0) *
                                                          passengers -
                                                      snapshot.data! * 100;
                                              useScore = true;
                                            } else {
                                              paymentInfo['amount'] =
                                                  (flight.price ?? 0) *
                                                      passengers;
                                              useScore = false;
                                            }
                                            context.read<PaymentBloc>().add(
                                                ToggleUseScore(
                                                    value,
                                                    paymentInfo['amount']
                                                        as int));
                                          }
                                        },
                                      ),
                                      Text('Sử dụng điểm để thanh toán'),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }
                    return SizedBox
                        .shrink(); // Hide if not in PaymentLoaded state
                  },
                ),
              ],
            ),
            SubmitButton(
              label: 'Thanh toán',
              onTap: () async {
                final userJson = await _storage.read(key: 'user_info');
                if (userJson != null) {
                  final accessToken =
                      AccountLogin.fromJson(jsonDecode(userJson)).accessToken;
                  final response = await http.post(
                    Uri.parse(
                        'http://10.0.2.2:8080/payment/create/?use_score=${useScore}'),
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
                                  'service': 'flight'
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Bạn cần đăng nhập để thanh toán."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text("Đóng"),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Thông báo"),
                      content: Text("Bạn cần đăng nhập để thanh toán."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text("Đóng"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
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
