import 'package:bankapp/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;  // Variable to hold the error message
 String? _successMessage; // Variable to hold the success message

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double padding = screenWidth * 0.08;

  return
  CupertinoPageScaffold(
    backgroundColor: const Color(0xFFE3F2FD),
    child: SafeArea(
      child: Stack(
        children: [
 // Background gradient circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1565C0).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF9A9A).withOpacity(0.2),
              ),
            ),
          ),

     SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         const SizedBox(height: 100),
                        const Text(
                          "BDO Secure Login",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Access your account safely",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF455A64),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Card container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email/Bank Number Field
                              CupertinoTextField(
                                controller: _usernameController,
                                placeholder: "Email or Bank Number",
                                placeholderStyle: const TextStyle(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                style: const TextStyle(fontSize: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFFB0BEC5)),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // PIN Field with toggle
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  CupertinoTextField(
                                    controller: _passwordController,
                                    placeholder: "PIN",
                                    obscureText: _obscurePassword,
                                    placeholderStyle: const TextStyle(color: Colors.grey),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    style: const TextStyle(fontSize: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Color(0xFFB0BEC5)),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                      color: Color(0xFF1E88E5),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  borderRadius: BorderRadius.circular(12),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: const Text("Log In", style: TextStyle(fontSize: 18)),
                                  onPressed: () async {
                                    String username = _usernameController.text.trim();
                                    String pin = _passwordController.text.trim();

                                    if (username.isEmpty || pin.isEmpty) {
                                      setState(() {
                                        _errorMessage = "Please fill in all fields.";
                                      });
                                      return;
                                    }

                                    try {
                                      var url = Uri.parse("https://orderingapp.shop/app/login.php");
                                      var response = await http.post(
                                        url,
                                        headers: {"Content-Type": "application/json"},
                                        body: jsonEncode({"username": username, "pin": pin}),
                                      );

                                      if (response.statusCode == 200) {
                                        var jsonResponse = jsonDecode(response.body);

                                        if (jsonResponse["status"] == "success") {
                                          setState(() {
                                            _successMessage = "Login Successful!";
                                            _errorMessage = null;
                                          });

                                          User user = User.fromJson(jsonResponse["data"]);

                                          Future.delayed(const Duration(seconds: 1), () {
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(builder: (_) => HomeScreen(user: user)),
                                            );
                                          });
                                        } else {
                                          setState(() {
                                            _errorMessage = jsonResponse["message"];
                                            _successMessage = null;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _errorMessage = "Unexpected error occurred. Please try again.";
                                          _successMessage = null;
                                        });
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _errorMessage = "Could not connect to server. Please try again.";
                                        _successMessage = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Messages
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
        ),


        ]

     ),
    ),
  );

}

}