import 'package:flutter/material.dart';

// Helper widget for destination tabs
class DestinationTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  DestinationTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
