import 'package:flutter/material.dart';

// Helper widget for the priority badges
class BadgeWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  BadgeWidget({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.orange)),
        SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
