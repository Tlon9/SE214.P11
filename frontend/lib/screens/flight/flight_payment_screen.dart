import 'package:flutter/material.dart';
import 'package:user_registration/models/flight_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user_registration/widgets/submit_button.dart';
import 'package:intl/intl.dart';

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
                              : Text('Khong co dich vu',
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
