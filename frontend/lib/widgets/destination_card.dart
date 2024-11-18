import 'package:flutter/material.dart';

// Helper widget for each destination card
class DestinationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('Vietravel Airline',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Hà Nội - TP HCM', style: TextStyle(color: Colors.grey)),
          Text('1,348.225', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
