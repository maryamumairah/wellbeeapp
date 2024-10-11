import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed; // A callback function to handle button press events.
  final Color color; // Customizable button color.
  final Color textColor; // Customizable text color.
  final double fontSize; // Font size of the button text.
  final FontWeight fontWeight; // Font weight of the button text.
  final String fontFamily;
  final int width; // Width of the button in pixels.
  final int height; // Height of the button in pixels.

  // Constructor to accept text, onPressed callback, optional color, text color, and font size.
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color.fromRGBO(254, 208, 114, 1), // Default button color.
    this.textColor = Colors.black, // Default text color is white.
    required this.width,
    required this.height,
    this.fontSize = 24, // Default font size is 24.
    this.fontWeight = FontWeight.bold,
    this.fontFamily = 'Inter',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.toDouble(), // Set the fixed width.
      height: height.toDouble(), // Set the fixed height.
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Set the button's primary color.
          padding: EdgeInsets.zero, // Remove default padding to ensure SizedBox dimensions are used.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Customize shape and border radius.
          ),
          // elevation: 5, // Adds shadow to the button for a 3D effect.
          // shadowColor: Colors.black.withOpacity(0.25), // Box shadow color and opacity.
          elevation: 10, // Increase elevation for a more pronounced shadow.
          shadowColor: Colors.black.withOpacity(0.5), // Box shadow color and opacity.
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center, // Ensures text is centered within the button.
            style: TextStyle(
              color: textColor, // Uses the specified text color.
              fontSize: fontSize, // Uses the specified font size.
              fontWeight: fontWeight, // Medium font weight.
              fontFamily: fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}