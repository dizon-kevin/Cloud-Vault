import 'package:cloud_vault/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'transfer_screen.dart';
import 'pay_bills_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class BankTransaction {
  final String type;
  final double amount;
  final String date;

  BankTransaction({
    required this.type,
    required this.amount,
    required this.date,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      type: json['Type'],
      amount: double.tryParse(json['Amount'].toString()) ?? 0.0,
      date: json['Date'],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late double _currentBalance;
  bool _showBalance = true;
  bool _showCardNumber = true;
  List<BankTransaction> _transactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _currentBalance = widget.user.balance;
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await http.post(
        Uri.parse('https://orderingapp.shop/app/get_balance.php'),
        body: {'accountId': widget.user.id.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final newBalance = double.tryParse(data['balance'].toString()) ?? 0.0;
          setState(() {
            _currentBalance = newBalance;
          });
        }
      }
    } catch (e) {
      print("Exception in fetchBalance: $e");
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.post(
        Uri.parse('https://orderingapp.shop/app/transaction.php'),
        body: {'accountId': widget.user.id.toString()},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await fetchBalance();
        if (responseData['status'].toString() == 'success') {
          List<dynamic> data = responseData['data'];
          setState(() {
            _transactions = data.map((t) => BankTransaction.fromJson(t)).toList();
            _isLoadingTransactions = false;
          });
        } else {
          setState(() {
            _isLoadingTransactions = false;
          });
        }
      } else {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE3F2FD),
        middle: Text(
          widget.user.bankName,
          style: const TextStyle(
            color: Color(0xFF0D47A1),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.settings,
            color: Color(0xFF0D47A1),
          ),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => SettingsPage(user: widget.user)),
            );
          },
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
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      _buildBalanceCard(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildBankCard(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ),
              _buildTransactionList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello,',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF455A64),
          ),
        ),
        Text(
          widget.user.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Account Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF455A64),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showBalance = !_showBalance),
                child: Icon(
                  _showBalance ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                  size: 20,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _showBalance ? '₱${_currentBalance.toStringAsFixed(2)}' : '••••••',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: CupertinoIcons.arrow_up_arrow_down,
          label: 'Transfer',
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => TransferPage(user: widget.user)),
            );
          },
        ),
        _buildActionButton(
          icon: CupertinoIcons.money_dollar,
          label: 'Pay Bills',
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => BillsPaymentPage(user: widget.user)),
            );
          },
        ),
        _buildActionButton(
          icon: CupertinoIcons.qrcode,
          label: 'Scan QR',
          onTap: () {},
        ),
        _buildActionButton(
          icon: CupertinoIcons.creditcard,
          label: 'Cards',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: Color(0xFF0D47A1),
          ),
          ),
           SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF455A64),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard() {
    String formatAccountNo(String accountNo) {
      return accountNo.replaceAllMapped(RegExp(r".{1,4}"), (match) => "${match.group(0)} ").trim();
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              widget.user.bankName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _showCardNumber ? formatAccountNo(widget.user.accountNo) : '•••• •••• ••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showCardNumber = !_showCardNumber),
                      child: const Icon(
                        CupertinoIcons.eye,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Exp: 12/24',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoadingTransactions) {
      return SliverFillRemaining(
        child: Center(
          child: CupertinoActivityIndicator(
            radius: 15,
            color: Color(0xFF0D47A1),
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No transactions found',
            style: TextStyle(
              color: Color(0xFF455A64),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = _transactions[index];
          final isIncome = tx.type.toLowerCase().contains("deposit") ||
                         tx.type.toLowerCase().contains("from");
          final formattedAmount =
              "${isIncome ? "+" : "-"} ₱${tx.amount.toStringAsFixed(2)}";

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CupertinoListTile(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isIncome
                      ? Color(0xFFE8F5E9).withOpacity(0.8)
                      : Color(0xFFFFEBEE).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isIncome ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
                  color: isIncome ? Color(0xFF2E7D32) : Color(0xFFC62828),
                  size: 20,
                ),
              ),
              title: Text(
                tx.type,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D47A1),
                ),
              ),
              subtitle: Text(
                tx.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF455A64),
                ),
              ),
              trailing: Text(
                formattedAmount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Color(0xFF2E7D32) : Color(0xFFC62828),
                ),
              ),
            ),
          );
        },
        childCount: _transactions.length,
      ),
    );
  }
}