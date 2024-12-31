import 'package:flutter/material.dart';

// Helper widget for each destination card
class DestinationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  DestinationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data['type'] == 'flight') {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, '/flight_result', arguments: {
          'departure': data['flight']['From'],
          'destination': data['flight']['To'],
          'date': data['flight']['Date'] != null
              ? DateTime.parse(
                  data['flight']['Date'].split('-').reversed.join('-'))
              : DateTime.now(),
          'seatClass': data['flight']['SeatClass'],
          'passengerCount': 1,
        }),
        child: Container(
          width: 150,
          margin: EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/destinationcard_form.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(data['flight']['Name'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${data['flight']['From']} - ${data['flight']['To']}',
                  style: TextStyle(color: Colors.grey)),
              Text(data['flight']['Price'].toString(),
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    } else if (data['type'] == 'hotel') {
      return InkWell(
        onTap: () => Navigator.pushNamed(
            context, '/hotel_result', // replace with your actual route
            arguments: {
              'area': data['hotel']['Area'],
              'checkInDate': DateTime.now(),
              'checkOutDate': DateTime.now().add(Duration(days: 1)),
              'customerCount': 1,
            }),
        child: Container(
          width: 150,
          margin: EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/destinationcard_form.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(data['hotel']['Name'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['hotel']['Area'], style: TextStyle(color: Colors.grey)),
              Text(data['hotel']['Price'].toString(),
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
