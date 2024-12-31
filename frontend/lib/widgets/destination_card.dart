import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatPrice(String price) {
  // Parse the string to an integer
  int value = int.tryParse(price) ?? 0;

  // Format the integer with a thousand separator
  return NumberFormat("#,###", "en_US").format(value).replaceAll(",", ".");
}

class DestinationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  DestinationCard({required this.data});
  Map<String, String> images = {
    'TP HCM (SGN)': 'assets/images/destinationcard_TP HCM (SGN).png',
    'Hà Nội (HAN)': 'assets/images/destinationcard_Hà Nội (HAN).png',
    'Đà Nẵng (DAD)': 'assets/images/destinationcard_Đà Nẵng (DAD).png',
  };

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
                    images[data['flight']['To']] ??
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
              Text(formatPrice(data['flight']['Price'].toString()) + ' VND',
                  style: TextStyle(
                    color: Colors.red,
                  )),
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
                  child: Image.network(
                    data['hotel']['Img'],
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/images/destinationcard_form.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                data['hotel']['Name'],
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                data['hotel']['Area'],
                style: TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(formatPrice(data['hotel']['Price'].toString()) + ' VND',
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
