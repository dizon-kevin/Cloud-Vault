import 'package:cloud_vault/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_model.dart';

class TransferReceiptPage extends StatelessWidget {
  final String recipientName;
  final String bank;
  final String accountNumber;
  final String amount;
  final User user;

  const TransferReceiptPage({
    super.key,
    required this.recipientName,
    required this.bank,
    required this.accountNumber,
    required this.amount,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final double parsedAmount = double.tryParse(amount) ?? 0.0;
    final double fee = 15.0;
    final double total = parsedAmount + fee;
    final String formattedDate = DateFormat('MMMM d, y – h:mm a').format(DateTime.now());

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
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Transfer Complete',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF607D8B),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInfoRow('Recipient', recipientName),
                      _buildInfoRow('Bank', bank),
                      _buildInfoRow('Account No.', accountNumber),
                      _buildInfoRow('Amount', '₱${parsedAmount.toStringAsFixed(2)}'),
                      _buildInfoRow('Transfer Fee', '₱${fee.toStringAsFixed(2)}'),
                      const Divider(height: 30, thickness: 1),
                      _buildInfoRow(
                        'Total Deducted',
                        '₱${total.toStringAsFixed(2)}',
                        isBold: true,
                        color: const Color(0xFF0D47A1),
                      ),
                      const SizedBox(height: 30),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        borderRadius: BorderRadius.circular(30),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 17),
                        ),
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF607D8B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: color ?? const Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }
}