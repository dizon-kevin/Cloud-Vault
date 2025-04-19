import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'login_screen.dart';

class SettingsPage extends StatelessWidget {
  final User user;
  const SettingsPage({super.key, required this.user});

  void logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE3F2FD),
        middle: Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
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

          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: CupertinoIcons.lock,
                          title: 'Change PIN',
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (context) => ChangePinPage(user: user)),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Section
                  Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),)
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: CupertinoIcons.power,
                          title: 'Log Out',
                          iconColor: Colors.red,
                          onTap: () => logout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Color(0xFF0D47A1),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF37474F),
              ),
            ),
            const Spacer(),
            if (iconColor == null) // Only show chevron for non-logout items
              Icon(
                CupertinoIcons.chevron_forward,
                color: Color(0xFF0D47A1),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class ChangePinPage extends StatefulWidget {
  final User user;
  const ChangePinPage({super.key, required this.user});

  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> initiatePinChange() async {
    final accountId = widget.user.id;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://orderingapp.shop/app/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accountId': accountId}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != null) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyOtpPage(accountId: accountId.toString()),
            ),
          );
        } else {
          _showMessage(data['error'] ?? 'Failed to send OTP.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Something went wrong. Please check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE3F2FD),
        middle: Text(
          'Change PIN',
          style: TextStyle(
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
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

          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_message != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isSuccess ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isSuccess ? Icons.check_circle : Icons.error,
                                  color: _isSuccess ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _message!,
                                    style: TextStyle(
                                      color: _isSuccess ? Colors.green[800] : Colors.red[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Text(
                          "To change your PIN, we'll send an OTP to your registered email.",
                          style: TextStyle(
                            color: Color(0xFF37474F),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        CupertinoButton.filled(
                          borderRadius: BorderRadius.circular(30),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: _isLoading ? null : initiatePinChange,
                          child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text(
                                'Send OTP',
                                style: TextStyle(fontSize: 18),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerifyOtpPage extends StatefulWidget {
  final String accountId;

  const VerifyOtpPage({super.key, required this.accountId});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _obscurePin = true;

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> verifyOtpAndChangePin() async {
    final otp = _otpController.text.trim();
    final newPin = _newPinController.text.trim();

    if (otp.isEmpty || newPin.isEmpty) {
      _showMessage('Please enter both OTP and new PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://orderingapp.shop/app/change_pin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accountId': widget.accountId,
          'otp': otp,
          'newPin': newPin,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != null) {
          _showMessage('PIN changed successfully!', success: true);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          });
        } else {
          _showMessage(data['error'] ?? 'Failed to change PIN.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE3F2FD),
        middle: Text(
          'Verify OTP',
          style: TextStyle(
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
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

          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (_message != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.error,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _isSuccess ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Enter OTP and New PIN",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please enter the OTP sent to your email and set your new PIN.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF607D8B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OTP Field
                        const Text(
                          'OTP',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF37474F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _otpController,
                          placeholder: 'Enter OTP',
                          keyboardType: TextInputType.number,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFB0BEC5),
                              width: 1,
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF37474F),
                            fontSize: 16,
                          ),
                          placeholderStyle: const TextStyle(
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // New PIN Field
                        const Text(
                          'New PIN',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF37474F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            CupertinoTextField(
                              controller: _newPinController,
                              placeholder: 'Enter New PIN',
                              keyboardType: TextInputType.number,
                              obscureText: _obscurePin,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFB0BEC5),
                                  width: 1,
                                ),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF37474F),
                                fontSize: 16,
                              ),
                              placeholderStyle: const TextStyle(
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePin = !_obscurePin;
                                  });
                                },
                                child: Icon(
                                  _obscurePin ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                  color: const Color(0xFF607D8B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            borderRadius: BorderRadius.circular(30),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: _isLoading ? null : verifyOtpAndChangePin,
                            child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text(
                                  'Change PIN',
                                  style: TextStyle(fontSize: 18),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}