import 'package:flutter/material.dart';
import 'package:ferrero_asset_management/widgets/styled_button.dart';
import 'package:ferrero_asset_management/screens/home/home_page.dart';
// import 'package:ferrero_app/utils/constants.dart'; // Uncomment if you use AppColors

class CompletionPage extends StatelessWidget {
  final String outletName;
  final String username;

  const CompletionPage({super.key, required this.outletName, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 100), // Use AppColors.greenSuccess
            const SizedBox(height: 20),
            const Text(
              'Asset Submitted successfully for approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            styledButton(
              text: 'Home Screen',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(username: username)),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
