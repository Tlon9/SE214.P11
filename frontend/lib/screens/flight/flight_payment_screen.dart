import 'package:flutter/material.dart';
import 'package:travelowkey/models/flight_model.dart';
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

class PaymentScreen extends StatelessWidget {
  final Flight flight;
  final int passengers;

  const PaymentScreen({required this.flight, required this.passengers});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> services = {
      'VietJet Air': [
        '7kg hanh ly xach tay',
        'wifi khong co san',
        'dich vu an uong',
        'airbus A350'
      ],
      'Vietnam Airlines': [
        '7kg hanh ly xach tay',
        'wifi khong co san',
        'dich vu an uong',
        'airbus A350'
      ],
      'Bamboo Airways': [
        '7kg hanh ly xach tay',
      ]
    };
    final Map<String, dynamic> paymentInfo = {
      'service': 'flight',
      'type': 'atm',
      'amount': (flight.price ?? 0) * (passengers ?? 0),
      'info': '${flight.flightId}-${passengers}',
      'extraData': '',
    };
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
              color: Colors.grey[200],
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
                        color: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200,
                            child: services[flight.name] != null
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: services[flight.name]
                                        .map<Widget>((service) => Text(service,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20)))
                                        .toList(),
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
            Text(
                "${formatMoney((flight.price as int) * passengers)} (${passengers} vé)",
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
            // SizedBox(height: 10),
            SubmitButton(
              label: 'Thanh toán',
              onTap: () async {
                final response = await http.post(
                  Uri.parse('http://10.0.2.2:8080/payment/create/'),
                  body: json.encode(paymentInfo),
                  headers: {'Content-Type': 'application/json'},
                );
                final data = json.decode(utf8.decode(response.bodyBytes));
                final transactionId = data['transaction_id'];
                if (data['url'] != null) {
                  final url = Uri.parse(data['url']);
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw Exception('Could not launch $url');
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

                    if (status != 'PENDING' || trial_count > 2) {
                      timer.cancel();
                      if (status == 'SUCCESS') {
                        // Navigate to the next screen
                        Navigator.pushNamed(context, '/invoice', arguments: {
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
                  throw Exception('URL is null');
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
