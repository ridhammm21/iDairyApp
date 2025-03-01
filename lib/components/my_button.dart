import 'package:flutter/material.dart';
import 'package:idairy/utils/global_colors.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GlobalColors.primary,
              Colors.blueAccent, // You can customize this color as needed
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30), // Increased corner radius for a softer look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 15), // Vertical padding
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), // Adjusted margins
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // Text color for contrast
              fontWeight: FontWeight.bold, // Bold text for emphasis
              fontSize: 16, // Increased font size
            ),
          ),
        ),
      ),
    );
  }
}
