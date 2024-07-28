import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'payment_detail_page.dart'; // Import the PaymentDetailPage

class SelectedMonthlyPaymentsPage extends StatefulWidget {
  @override
  _SelectedMonthlyPaymentsPageState createState() =>
      _SelectedMonthlyPaymentsPageState();
}

class _SelectedMonthlyPaymentsPageState
    extends State<SelectedMonthlyPaymentsPage> {
  List<Map<String, dynamic>> payments = [];
  double totalPayments = 0.0;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<int> months = [];
  List<int> years = [];

  @override
  void initState() {
    super.initState();
    initializeMonthsAndYears();
    fetchMonthlyPayments(selectedMonth, selectedYear);
  }

  void initializeMonthsAndYears() {
    months = List.generate(12, (index) => index + 1);
    years = List.generate(5, (index) => DateTime.now().year - index);
  }

  Future<void> fetchMonthlyPayments(int month, int year) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://child.codingindia.co.in/Accounts/total-payments-selected-month/?month=$month&year=$year'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> paymentsData = data['payments'];

        setState(() {
          payments = paymentsData
              .map<Map<String, dynamic>>((payment) => {
                    'date_paid': payment['date_paid'],
                    'amount': payment['amount'],
                    'childName': payment['child_name'], // Add childName
                  })
              .toList();
          totalPayments = double.parse(data['total_payments']
              .toString()); // Convert to string before parsing
        });
      } else {
        print('Failed to fetch monthly payments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly payments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monthly Payments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: months.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '${_getMonthName(value)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                      fetchMonthlyPayments(selectedMonth, selectedYear);
                    });
                  },
                ),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: selectedYear,
                  items: years.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                      fetchMonthlyPayments(selectedMonth, selectedYear);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Payment Records',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentDetailPage(
                            datePaid: payment['date_paid'],
                            amount: double.parse(payment['amount']),
                            childName: payment['childName'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          'Date: ${payment['date_paid']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'From: ${payment['childName']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Amount: \$${payment['amount']}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF0891B2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '\$${totalPayments.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
