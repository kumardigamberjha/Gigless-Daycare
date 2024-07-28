import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:childcare/Screens/Fees/monthly_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeeFormPageForParent extends StatefulWidget {
  final int childId;

  FeeFormPageForParent(this.childId);

  @override
  _FeeFormPageForParentState createState() => _FeeFormPageForParentState();
}

class _FeeFormPageForParentState extends State<FeeFormPageForParent> {
  final TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;
  double childFeesPaidThisMonth = 0;
  double childFeesLeft = 0;

  @override
  void initState() {
    super.initState();
    fetchChildFees();
  }

  Future<void> fetchChildFees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      // Access token not found in shared preferences
      // Handle this case accordingly, e.g., show error message and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access token not found. Please login again.')),
      );
      return;
    }

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final String apiUrl =
        'https://child.codingindia.co.in/Parent/Fees/${widget.childId}/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final fees = responseData['fees'] as List<dynamic>;
        double totalPaidThisMonth = 0;

        for (var fee in fees) {
          final feeDate = DateTime.parse(fee['date_paid']);
          if (feeDate.isAfter(firstDayOfMonth) &&
              feeDate.isBefore(lastDayOfMonth)) {
            final feeAmount =
                double.parse(fee['amount']); // Parse amount as double
            totalPaidThisMonth += feeAmount;
          }
        }

        final childFees = responseData['child_fees'] as double;

        setState(() {
          childFeesPaidThisMonth = totalPaidThisMonth;
          childFeesLeft = childFees - totalPaidThisMonth;
        });
      } else {
        // Failed to fetch child fees
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch child fees')),
        );
      }
    } catch (e) {
      // Handle network error
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again later.')),
      );
    }
  }

  Future<void> saveFee() async {
    setState(() {
      isSaving = true;
    });

    final String apiUrl =
        'https://child.codingindia.co.in/Accounts/Fees/${widget.childId}/';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'child': widget.childId,
        'amount': double.parse(amountController.text),
        'date_paid': _formatDate(selectedDate),
      }),
    );

    setState(() {
      isSaving = false;
    });

    if (response.statusCode == 201) {
      // Fee saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fee saved successfully')),
      );
    } else {
      // Failed to save fee
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save fee')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Fee',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Fee Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Child Fees Paid This Month: $childFeesPaidThisMonth',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              'Child Fees Left This Month: $childFeesLeft',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate)
      setState(() {
        selectedDate = pickedDate;
      });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
