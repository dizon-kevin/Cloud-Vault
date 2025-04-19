import 'package:cloud_vault/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';

class BillsPaymentPage extends StatelessWidget {
  const BillsPaymentPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.back, color: Color(0xFF0D47A1)),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                            ),),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Bills Payment',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                      ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Glass card container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
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
                            'Select a biller to pay',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF455A64),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Billers List
                          Expanded(child: _buildBillerList(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillerList(BuildContext context) {
    final List<Map<String, dynamic>> billers = [
      {
        "name": "Electricity",
        "icon": CupertinoIcons.bolt_fill,
        "color": Color(0xFFFFA000), // Amber
      },
      {
        "name": "Water",
        "icon": CupertinoIcons.drop_fill,
        "color": Color(0xFF00ACC1), // Cyan
      },
      {
        "name": "Internet",
        "icon": CupertinoIcons.wifi,
        "color": Color(0xFF7E57C2), // Purple
      },
    ];

    return ListView.separated(
      itemCount: billers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final biller = billers[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    BillPaymentFormPage(biller: biller['name'], user: user),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: biller['color'].withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    biller['icon'],
                    size: 24,
                    color: biller['color'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    biller['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 20,
                  color: Color(0xFF90A4AE),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BillPaymentFormPage extends StatefulWidget {
  final String biller;
  final User user;

  const BillPaymentFormPage({
    super.key,
    required this.biller,
    required this.user,
  });

  @override
  _BillPaymentFormPageState createState() => _BillPaymentFormPageState();
}

class _BillPaymentFormPageState extends State<BillPaymentFormPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _submitPayment() async {
    final amount = _amountController.text.trim();
    final accNum = _accountNumberController.text.trim();

    if (amount.isEmpty || accNum.isEmpty) {
      _setMessage("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://orderingapp.shop/app/pay_bills.php'),
        body: {
          'user_id': widget.user.id.toString(),
          'biller': widget.biller,
          'amount': amount,
          'account_number': accNum,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("Server response: ${response.body}");
          _setMessage("You have successfully paid ₱$amount for ${widget.biller}", success: true);
        } else {
          _setMessage("Payment failed: ${jsonResponse['message']}");
        }
      } else {
        _setMessage("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _setMessage("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _setMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    if (success) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // go back to biller list
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ReceiptPage(
              biller: widget.biller,
              amount: _amountController.text,
              accountNumber: _accountNumberController.text,
              user: widget.user,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.back, color: Color(0xFF0D47A1)),
                            SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Pay ${widget.biller}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Glass card container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
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
                          if (_message != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
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

                          _buildTextField(
                            controller: _accountNumberController,
                            label: 'Account Number',
                            placeholder: 'Enter account number',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _amountController,
                            label: 'Amount (₱)',
                            placeholder: 'Enter amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 40),

                          _isLoading
                              ? const Center(child: CupertinoActivityIndicator())
                              : CupertinoButton.filled(
                                  borderRadius: BorderRadius.circular(30),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  onPressed: _submitPayment,
                                  child: const Text(
                                    'Pay Now',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: const EdgeInsets.all(16),
          keyboardType: keyboardType,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFCFD8DC),
              width: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class ReceiptPage extends StatelessWidget {
  final String biller;
  final String amount;
  final String accountNumber;
  final User user;

  const ReceiptPage({
    super.key,
    required this.biller,
    required this.amount,
    required this.user,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    final double amountValue = double.tryParse(amount) ?? 0;
    final double totalAmount = amountValue + 15;
    final String formattedDate = DateTime.now().toString().substring(0, 16);

    return CupertinoPageScaffold(
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

            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 25,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        size: 70,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildRow('Date', formattedDate),
                      _buildRow('Biller', biller),
                      _buildRow('Account No.', accountNumber),
                      _buildRow('Amount', '₱$amount'),
                      _buildRow('Fee', '₱15.00'),
                      const Divider(height: 30, thickness: 1),
                      _buildRow(
                        'Total Paid',
                        '₱${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      const SizedBox(height: 30),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        borderRadius: BorderRadius.circular(30),
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => HomeScreen(user: user),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF455A64),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}