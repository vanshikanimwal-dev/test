// lib/screens/image_viewer/image_viewer_screen.dart

import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String title;
  final String imageAssetPath; // Path to the image asset

  const ImageViewerScreen({
    Key? key,
    required this.title,
    required this.imageAssetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView( // Allows scrolling if the image is taller than the screen
          child: Image.asset(
            imageAssetPath,
            fit: BoxFit.contain, // Ensures the image fits within bounds
            errorBuilder: (context, error, stackTrace) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading image: Check asset path. $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}