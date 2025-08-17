import 'package:flutter/material.dart';
// import 'package:ferrero_app/utils/constants.dart'; // Uncomment if you use AppColors, AppAssets

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool showTimer;
  final String timerText;
  final VoidCallback? onResendPressed;
  final bool canResend;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.buttonText,
    required this.onButtonPressed,
    this.showTimer = false,
    this.timerText = '',
    this.onResendPressed,
    this.canResend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 18, color: Colors.brown),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/rect1.png'), // Use AppAssets.rect1 if you uncommented the import
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: onButtonPressed == null ? Colors.grey : Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
        if (showTimer)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 5.0),
            child: Text(
              'Resend in: $timerText',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
        if (!showTimer && canResend)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: TextButton(
                onPressed: onResendPressed,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: onResendPressed != null ? Colors.blue.shade700 : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
