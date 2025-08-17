
import 'dart:io';
import 'package:flutter/material.dart';

class PhotoCaptureGridItem extends StatelessWidget {
  final String label;
  final String? pickedFilePath; // Local file path (e.g., from camera)
  final String? networkImageUrl; // Network URL (e.g., from database)
  final VoidCallback onTap;
  final bool isEditable;

  const PhotoCaptureGridItem({
    super.key,
    required this.label,
    this.pickedFilePath,
    this.networkImageUrl, // New property for network images
    required this.onTap,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which image path to use: local takes precedence over network
    // Ensure null-safety when checking for empty strings
    final String? imageToDisplayPath = (pickedFilePath != null && pickedFilePath!.isNotEmpty)
        ? pickedFilePath
        : (networkImageUrl != null && networkImageUrl!.isNotEmpty)
        ? networkImageUrl
        : null;

    final bool isNetworkImage = (pickedFilePath == null || pickedFilePath!.isEmpty) &&
        (networkImageUrl != null && networkImageUrl!.isNotEmpty);

    return GestureDetector(
      onTap: isEditable ? onTap : null, // Only allow tap if editable
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageToDisplayPath != null && imageToDisplayPath.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isNetworkImage
                      ? Image.network(
                    imageToDisplayPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.brown,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading network image for ${label} ($imageToDisplayPath): $error');
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  )
                      : Image.file( // Local file path
                    File(imageToDisplayPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading local image for ${label} ($imageToDisplayPath): $error');
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              )
            else // No image path available
              Icon(
                Icons.camera_alt,
                size: 40,
                color: isEditable ? Colors.brown : Colors.grey,
              ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isEditable ? Colors.brown : Colors.grey,
              ),
            ),
            // Show "Tap to Retake" only if editable and an image is present (local or network)
            if (imageToDisplayPath != null && imageToDisplayPath.isNotEmpty && isEditable)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tap to Retake',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}