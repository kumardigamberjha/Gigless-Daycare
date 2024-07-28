import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Fee {
  final int id;
  final int childId;
  final String childName;
  final double amount;
  final String datePaid;

  Fee({
    required this.id,
    required this.childId,
    required this.childName,
    required this.amount,
    required this.datePaid,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['id'],
      childId: json['child'],
      childName: json['child_name'] ?? 'Unknown',
      amount: double.parse(json['amount'].toString()),
      datePaid: json['date_paid'],
    );
  }
}

class FeeListPage extends StatefulWidget {
  final int childId;

  FeeListPage({required this.childId});

  @override
  _FeeListPageState createState() => _FeeListPageState();
}

class _FeeListPageState extends State<FeeListPage> {
  List<Fee> fees = [];
  bool isLoading = true;
  String errorMessage = '';
  List<int> months = [];
  int selectedMonth = DateTime.now().month;
  String childName = '';

  @override
  void initState() {
    super.initState();
    fetchFees();
  }

  Future<void> fetchFees() async {
    try {
      final response = await http.get(Uri.parse(
          'https://child.codingindia.co.in/Accounts/Fees/${widget.childId}/'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> feesJson = jsonData['fees'];

        setState(() {
          fees = feesJson.map((data) => Fee.fromJson(data)).toList();
          childName = jsonData['child_name'] ?? 'Unknown';
          months = fees
              .map((fee) => DateTime.parse(fee.datePaid).month)
              .toSet()
              .toList();
          selectedMonth = months.isNotEmpty ? months[0] : DateTime.now().month;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load fees';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching fees: $e');
      setState(() {
        errorMessage = 'An error occurred while fetching fees';
        isLoading = false;
      });
    }
  }

  double getTotalAmountReceivedForMonth(int month) {
    final feesForMonth = fees.where((fee) {
      final feeMonth = DateTime.parse(fee.datePaid).month;
      return feeMonth == month;
    });

    double totalAmount = 0;
    for (var fee in feesForMonth) {
      totalAmount += fee.amount;
    }

    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fee List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  // Wrap your content with SingleChildScrollView
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value!;
                            });
                          },
                          items: months.map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                  '${DateFormat.MMMM().format(DateTime(2022, value))}'),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            'Child Name: $childName',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: fees.length,
                        itemBuilder: (context, index) {
                          final fee = fees[index];
                          final feeMonth = DateTime.parse(fee.datePaid).month;
                          if (feeMonth != selectedMonth) {
                            // Skip fees that don't match the selected month
                            return SizedBox.shrink();
                          }
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text('Date: ${fee.datePaid}'),
                              subtitle: Text(
                                'Amount: \$${fee.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              Text(
                                '\$${getTotalAmountReceivedForMonth(selectedMonth).toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FeeListPage(childId: 1),
  ));
}
