import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import 'transfer_receipt.dart';
import 'package:hive/hive.dart';

class TransferPage extends StatelessWidget {
  final User user;
  const TransferPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final Box savedAccountsBox = Hive.box('savedAccounts');
    final List<Map<String, String>> savedAccounts = savedAccountsBox.values
        .cast<Map>()
        .map((e) => Map<String, String>.from(e))
        .toList();

    final List<String> partnerBanks = [
      "BDO", "Landbank", "PNB", "China Bank",
      "Union Bank", "BPI", "RCBC"
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: Color(0xFF0D47A1),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Transfer Funds',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a saved account or partner bank',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF607D8B),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Saved Accounts Section
                  const Text(
                    'Saved Accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (savedAccounts.isEmpty)
                    _buildEmptyState(
                      icon: CupertinoIcons.bookmark,
                      message: 'No saved accounts yet',
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: savedAccounts.map((acc) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => TransferFormPage(
                                    bankOrAccount: acc['bank']!,
                                    accountId: user.id.toString(),
                                    initialName: acc['name']!,
                                    initialAccount: acc['account']!,
                                    user: user,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(18),
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
                                  Text(
                                    acc['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${acc['bank']} • ${acc['account']}",
                                    style: const TextStyle(
                                      color: Color(0xFF607D8B),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      CupertinoIcons.chevron_back,
                                      color: Color(0xFF1565C0),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Partner Banks Section
                  const Text(
                    'Partner Banks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
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
                      children: partnerBanks.map((bank) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => TransferFormPage(
                                  bankOrAccount: bank,
                                  accountId: user.id.toString(),
                                  user: user,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    bank,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: Color(0xFF90A4AE),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
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
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF90A4AE),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF607D8B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class TransferFormPage extends StatefulWidget {
  final String bankOrAccount;
  final String accountId;
  final String? initialName;
  final String? initialAccount;
  final User user;

  const TransferFormPage({
    super.key,
    required this.bankOrAccount,
    required this.accountId,
    required this.user,
    this.initialName,
    this.initialAccount,
  });

  @override
  TransferFormPageState createState() => TransferFormPageState();
}

class TransferFormPageState extends State<TransferFormPage> {
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _message;
  bool _isSuccess = false;
  final String _transferApiUrl = "https://orderingapp.shop/app/transfer.php";

  Future<void> _submitTransfer() async {
    final name = _recipientNameController.text.trim();
    final account = _accountNumberController.text.trim();
    final amount = _amountController.text.trim();
    final bank = widget.bankOrAccount;
    final accountId = widget.accountId;

    if (name.isEmpty || account.isEmpty || amount.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_transferApiUrl),
        body: {
          "accountId": accountId,
          "recipientBankName": bank,
          "recipientAccountNumber": account,
          "amount": amount,
        },
      );

      final json = jsonDecode(response.body);
      if (json.containsKey('success')) {
        _showMessage(json['success'], success: true);
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => TransferReceiptPage(
                recipientName: name,
                bank: bank,
                accountNumber: account,
                amount: amount,
                user: widget.user,
              ),
            ),
          );
        });
      } else if (json.containsKey('error')) {
        _showMessage(json['error']);
      } else {
        _showMessage('Transfer failed.');
      }
    } catch (e) {
      _showMessage("Failed to connect to server.");
    }
  }

  Future<void> _saveAccountToHive() async {
    final name = _recipientNameController.text.trim();
    final bank = widget.bankOrAccount;
    final account = _accountNumberController.text.trim();

    if (name.isEmpty || account.isEmpty) {
      _showMessage("Please fill out recipient name and account number.");
      return;
    }

    final box = await Hive.openBox('savedAccounts');

    bool accountExists = false;
    for (var savedAccount in box.values) {
      if (savedAccount['account'] == account && savedAccount['bank'] == bank) {
        accountExists = true;
        break;
      }
    }

    if (accountExists) {
      _showMessage("This account is already saved.");
      return;
    }

    await box.add({
      'name': name,
      'bank': bank,
      'account': account,
    });

    _showMessage("Account saved successfully!", success: true);
  }

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  @override
  void initState() {
    super.initState();
    _recipientNameController.text = widget.initialName ?? '';
    _accountNumberController.text = widget.initialAccount ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: Color(0xFF0D47A1),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Transfer to ${widget.bankOrAccount}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter recipient details to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF607D8B),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Flash message
                  if (_message != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? Colors.green[100]?.withOpacity(0.9)
                            : Colors.red[100]?.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.error,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _isSuccess
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Form Container
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
                        _buildTextField(
                          controller: _recipientNameController,
                          label: 'Recipient Name',
                          placeholder: 'Enter full name',
                          icon: CupertinoIcons.person_fill,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _accountNumberController,
                          label: 'Account Number',
                          placeholder: 'Enter account number',
                          keyboardType: TextInputType.number,
                          icon: CupertinoIcons.number_square_fill,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _amountController,
                          label: 'Amount (₱)',
                          placeholder: 'Enter amount',
                          keyboardType: TextInputType.number,
                          icon: CupertinoIcons.money_dollar_circle_fill,
                        ),
                        const SizedBox(height: 25),

                        // Save Account Button
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFE3F2FD),
                            onPressed: _saveAccountToHive,
                            child: const Text(
                              'Save Account for Future',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Transfer Button
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            borderRadius: BorderRadius.circular(30),
                            onPressed: _submitTransfer,
                            child: const Text(
                              'Confirm Transfer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: const EdgeInsets.all(16),
          keyboardType: keyboardType,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              icon,
              color: const Color(0xFF1565C0),
              size: 22,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF263238),
            fontSize: 16,
          ),
          placeholderStyle: const TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}