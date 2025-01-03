import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  SubmitButton({required this.label, this.onTap});

  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF4800),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            textStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))));
  }
}
