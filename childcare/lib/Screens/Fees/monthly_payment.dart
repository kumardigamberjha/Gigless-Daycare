import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TotalPaymentsCurrentMonthPage extends StatefulWidget {
  @override
  _TotalPaymentsCurrentMonthPageState createState() =>
      _TotalPaymentsCurrentMonthPageState();
}

class _TotalPaymentsCurrentMonthPageState
    extends State<TotalPaymentsCurrentMonthPage> {
  List<Map<String, String>> payments = [];
  double totalPayments = 0.0;

  @override
  void initState() {
    super.initState();
    fetchTotalPaymentsCurrentMonth();
  }

  Future<void> fetchTotalPaymentsCurrentMonth() async {
    try {
      final response = await http.get(Uri.parse(
          'https://child.codingindia.co.in/Accounts/total-payments-current-month/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> paymentsData = data['payments'];

        setState(() {
          payments = paymentsData
              .map<Map<String, String>>((payment) => {
                    'date_paid': payment['date_paid'],
                    'amount': payment['amount'],
                  })
              .toList();
          totalPayments = double.parse(data['total_payments']);
        });
      } else {
        print('Failed to fetch total payments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching total payments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monthly Revenue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Payment Records',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        'Date Paid: ${payment['date_paid']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        'Amount: \$${payment['amount']}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total Payments: \$${totalPayments.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
