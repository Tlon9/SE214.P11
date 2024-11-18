import 'package:flutter/material.dart';

// Helper widget for service buttons
class ServiceButton extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final String label;
  final VoidCallback? onTap;

  ServiceButton(
      {required this.icon,
      this.backgroundColor,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: backgroundColor ?? Colors.grey.shade100,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
