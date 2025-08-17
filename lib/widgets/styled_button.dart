import 'package:flutter/material.dart';
// import 'package:ferrero_app/utils/constants.dart'; // Uncomment if you use AppAssets

// Reusable styled button widget
Widget styledButton({
  required String text,
  required VoidCallback? onPressed,
  Color buttonColor = Colors.brown, // Note: This parameter is not used in the current implementation due to image background
  double width = 250,
  double height = 50,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      image: const DecorationImage(
        image: AssetImage('assets/rect1.png'), // Use AppAssets.rect1 if you uncommented the import
        fit: BoxFit.cover,
        repeat: ImageRepeat.repeat,
        colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 5,
          spreadRadius: 1,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
