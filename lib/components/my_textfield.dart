import 'package:flutter/material.dart';
import 'package:idairy/utils/global_colors.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: GlobalColors.tertiary.withOpacity(0.9), // Slightly transparent background
          borderRadius: BorderRadius.circular(30), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow for depth
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: TextField(
          obscureText: _isObscured,
          controller: widget.controller,
          style: TextStyle(color: GlobalColors.primary, fontSize: 16), // Text style
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: GlobalColors.textColor.withOpacity(0.6)), // Hint text style
            border: InputBorder.none, // Removes the border
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Padding inside the text field
            suffixIcon: widget.hintText.toLowerCase().contains("password")
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                      color: GlobalColors.primary,
                    ),
                    onPressed: _toggleVisibility,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
