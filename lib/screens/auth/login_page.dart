//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:ferrero_asset_management/widgets/styled_button.dart';
// import 'package:ferrero_asset_management/screens/home/home_page.dart';
// // REMOVE THIS LINE: You no longer need the global token
// // import 'package:ferrero_asset_management/screens/auth/global_auth_token.dart' as globals;
//
// // ADD THESE IMPORTS:
// import 'package:provider/provider.dart';
// import 'package:ferrero_asset_management/provider/data_provider.dart';
//
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _userIdController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _obscurePassword = true;
//
//   static const MethodChannel _authChannel = MethodChannel('com.example.ferrero_asset_management/auth');
//
//
//   void _login() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     final String username = _userIdController.text.trim();
//     final String password = _passwordController.text.trim();
//
//     if (username.isEmpty || password.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter both User ID and Password.';
//         _isLoading = false;
//       });
//       return;
//     }
//
//     try {
//       final String? authToken = await _authChannel.invokeMethod(
//         'requestAuthToken',
//         {'username': username, 'password': password},
//       );
//
//       if (authToken != null && authToken.isNotEmpty) {
//         print('Authentication Successful! Token: $authToken');
//
//         // --- NEW: Store token in DataProvider ---
//         final dataProvider = Provider.of<DataProvider>(context, listen: false);
//         dataProvider.setBearerToken(authToken);
//         // --- END NEW ---
//
//         // REMOVE THIS LINE: No longer needed
//         // globals.authToken = authToken;
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Login Successful!')),
//         );
//
//         _userIdController.clear();
//         _passwordController.clear();
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomePage( // Assuming HomePage eventually leads to SearchPage
//             username: username,
//           )),
//         );
//
//       } else {
//         setState(() {
//           _errorMessage = 'Authentication failed: No token received.';
//         });
//       }
//     } on PlatformException catch (e) {
//       print("Failed to get auth token: '${e.code}': '${e.message}'. Details: ${e.details}");
//       setState(() {
//         _errorMessage = 'Login failed: ${e.message ?? "Unknown authentication error"}';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login Failed: ${e.message ?? "Authentication Error"}')),
//       );
//     } catch (e) {
//       print("An unexpected error occurred during login: $e");
//       setState(() {
//         _errorMessage = 'An unexpected error occurred: $e';
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An unexpected error occurred.')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBF4EF),
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset('assets/homescreen.png', fit: BoxFit.cover),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 30.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/logo.png', height: 150, width: 150),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'Ferrero Asset Management App',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3E2723),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 25),
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 20.0),
//                     decoration: BoxDecoration(
//                       image: const DecorationImage(
//                         image: AssetImage('assets/rect1.png'),
//                         fit: BoxFit.cover,
//                         repeat: ImageRepeat.repeat,
//                       ),
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: TextField(
//                       controller: _userIdController,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         hintText: 'Enter your user id',
//                         hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//                         border: InputBorder.none,
//                         prefixIcon: const Icon(Icons.person, color: Colors.white70),
//                       ),
//                       keyboardType: TextInputType.text,
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 40.0),
//                     decoration: BoxDecoration(
//                       image: const DecorationImage(
//                         image: AssetImage('assets/rect1.png'),
//                         fit: BoxFit.cover,
//                         repeat: ImageRepeat.repeat,
//                       ),
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: TextField(
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         hintText: 'Enter your password',
//                         hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//                         border: InputBorder.none,
//                         prefixIcon: const Icon(Icons.lock, color: Colors.white70),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                             color: Colors.white70,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       keyboardType: TextInputType.text,
//                     ),
//                   ),
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 10),
//                       child: Text(
//                         _errorMessage!,
//                         style: const TextStyle(color: Colors.redAccent, fontSize: 14),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   _isLoading
//                       ? const CircularProgressIndicator(color: Color(0xFF5D4037))
//                       : styledButton(text: 'Login', onPressed: _login),
//                   const SizedBox(height: 80),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20.0,
//             left: 0,
//             right: 0,
//             child: const Text(
//               '© Ferrero 2022. All rights reserved.',
//               style: TextStyle(fontSize: 12, color: Colors.black),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ferrero_asset_management/widgets/styled_button.dart';
import 'package:ferrero_asset_management/screens/home/home_page.dart';

// ADD THESE IMPORTS:
import 'package:provider/provider.dart';
import 'package:ferrero_asset_management/provider/data_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // For Admin Login
  final TextEditingController _adminUserIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  // For Salesman Login (hardcoded)
  final TextEditingController _salesmanPhoneController = TextEditingController();
  final TextEditingController _salesmanPasswordController = TextEditingController();

  String? _selectedUserType; // 'admin', 'salesman', or null
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  static const MethodChannel _authChannel = MethodChannel('com.example.ferrero_asset_management/auth');


  void _loginAdmin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String username = _adminUserIdController.text.trim();
    final String password = _adminPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both User ID and Password.';
        _isLoading = false;
      });
      return;
    }

    try {
      final String? authToken = await _authChannel.invokeMethod(
        'requestAuthToken',
        {'username': username, 'password': password},
      );

      if (authToken != null && authToken.isNotEmpty) {
        print('Authentication Successful! Token: $authToken');

        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.setBearerToken(authToken);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );

        _adminUserIdController.clear();
        _adminPasswordController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(
            username: username,
          )),
        );

      } else {
        setState(() {
          _errorMessage = 'Authentication failed: No token received.';
        });
      }
    } on PlatformException catch (e) {
      print("Failed to get auth token: '${e.code}': '${e.message}'. Details: ${e.details}");
      setState(() {
        _errorMessage = 'Login failed: ${e.message ?? "Unknown authentication error"}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.message ?? "Authentication Error"}')),
      );
    } catch (e) {
      print("An unexpected error occurred during login: $e");
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loginSalesman() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String phoneNumber = _salesmanPhoneController.text.trim();
    final String password = _salesmanPasswordController.text.trim();

    // Hardcoded credentials for Salesman
    const String hardcodedPhone = '7838989931';
    const String hardcodedPassword = '123456';

    if (phoneNumber == hardcodedPhone && password == hardcodedPassword) {
      print('Salesman Login Successful!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salesman Login Successful!')),
      );

      _salesmanPhoneController.clear();
      _salesmanPasswordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(
          username: 'Salesman', // You can use a more descriptive name or the phone number
        )),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid phone number or password.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Failed: Invalid credentials')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _adminUserIdController.dispose();
    _adminPasswordController.dispose();
    _salesmanPhoneController.dispose();
    _salesmanPasswordController.dispose();
    super.dispose();
  }

  Widget _buildUserSelectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 150, width: 150),
          const SizedBox(height: 15),
          const Text(
            'Ferrero Asset Management App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          styledButton(
            text: 'Admin',
            onPressed: () {
              setState(() {
                _selectedUserType = 'admin';
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 20),
          styledButton(
            text: 'Salesman',
            onPressed: () {
              setState(() {
                _selectedUserType = 'salesman';
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminLoginView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
            onPressed: () {
              setState(() {
                _selectedUserType = null;
                _errorMessage = null;
              });
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150, width: 150),
                const SizedBox(height: 15),
                const Text(
                  'Admin Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/rect1.png'),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _adminUserIdController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your user id',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/rect1.png'),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _adminPasswordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF5D4037))
                    : styledButton(text: 'Login', onPressed: _loginAdmin),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesmanLoginView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
            onPressed: () {
              setState(() {
                _selectedUserType = null;
                _errorMessage = null;
              });
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 150, width: 150),
                const SizedBox(height: 15),
                const Text(
                  'Salesman Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/rect1.png'),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _salesmanPhoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 40.0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/rect1.png'),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _salesmanPasswordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF5D4037))
                    : styledButton(text: 'Login', onPressed: _loginSalesman),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4EF),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/homescreen.png', fit: BoxFit.cover),
          ),
          _selectedUserType == 'admin'
              ? _buildAdminLoginView()
              : _selectedUserType == 'salesman'
              ? _buildSalesmanLoginView()
              : _buildUserSelectionView(),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: const Text(
              '© Ferrero 2022. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
