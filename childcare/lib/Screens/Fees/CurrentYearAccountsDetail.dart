import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrentYearAccountDetailPage extends StatefulWidget {
  @override
  _CurrentYearAccountDetailPageState createState() =>
      _CurrentYearAccountDetailPageState();
}

class _CurrentYearAccountDetailPageState
    extends State<CurrentYearAccountDetailPage> {
  List<Map<String, dynamic>> accountDetails = [];
  double totalAmount = 0.0;
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentYearAccountDetails();
  }

  Future<void> fetchCurrentYearAccountDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://child.codingindia.co.in/Accounts/current-year-payments/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> paymentsData = data['payments_by_month'];

        setState(() {
          accountDetails = paymentsData.cast<Map<String, dynamic>>();
          totalAmount = double.parse(data['total_amount'].toString());
          isLoading = false;
        });
      } else {
        showErrorSnackBar(
            'Failed to fetch account details: ${response.statusCode}');
      }
    } catch (e) {
      showErrorSnackBar('Error fetching account details: $e');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Current Year Revenue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue by Month',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: accountDetails.length,
                itemBuilder: (context, index) {
                  final monthData = accountDetails[index];
                  final monthYear = monthData['month_year'];
                  final totalAmount = monthData['total_amount_month'];
                  final payments = monthData['payments'] ?? [];

                  return MonthTile(
                    monthYear: monthYear,
                    totalAmount: totalAmount,
                    payments: payments,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _buildTotalAmount(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0891B2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class MonthTile extends StatefulWidget {
  final String monthYear;
  final double totalAmount;
  final List<dynamic> payments; // Change this to List<dynamic>

  const MonthTile({
    required this.monthYear,
    required this.totalAmount,
    required this.payments,
    Key? key,
  }) : super(key: key);

  @override
  _MonthTileState createState() => _MonthTileState();
}

class _MonthTileState extends State<MonthTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            '${widget.monthYear} - Total Revenue: \$${widget.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: IconButton(
            icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        if (_isExpanded) ...[
          for (var payment in widget.payments.cast<
              Map<String,
                  dynamic>>()) // Cast payments to List<Map<String, dynamic>>
            _buildAccountItem(payment),
        ],
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAccountItem(Map<String, dynamic> payment) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${payment['date']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            'From: ${payment['child_name']}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            'Amount: \$${payment['amount'].toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
