import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationGridItem extends StatelessWidget {
  final bool isFetching;
  final String message;
  final Position? currentPosition;
  final VoidCallback onTap;
  final bool isLocationCaptured;

  const LocationGridItem({
    super.key,
    required this.isFetching,
    required this.message,
    this.currentPosition,
    required this.onTap,
    required this.isLocationCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFetching ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isFetching
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.brown[400]),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.brown[700]),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 40, color: Colors.brown[400]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  isLocationCaptured ? 'Location Captured' : 'Asset Location',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.brown[700]),
                ),
              ),
              if (currentPosition != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'Lat: ${currentPosition!.latitude.toStringAsFixed(4)}\nLng: ${currentPosition!.longitude.toStringAsFixed(4)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}