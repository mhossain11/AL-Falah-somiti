import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BuildTransactionsList extends StatefulWidget {
   BuildTransactionsList({super.key ,required this.currentUserId});
  String currentUserId;
  @override
  State<BuildTransactionsList> createState() => _BuildTransactionsListState();
}

class _BuildTransactionsListState extends State<BuildTransactionsList> {


  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('Money')
          .orderBy('date&time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.money_off, size: 60.sp, color: Colors.grey),
                SizedBox(height: 10.h),
                Text(
                  'No transactions found',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
                SizedBox(height: 10.h),
                Text(
                  'This user has no financial transactions yet',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final transactions = snapshot.data!.docs;
        final totalAmount = transactions.fold<double>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0;
          return sum + amount;
        });

        return Column(
          children: [
            // Summary Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              child: Row(
                children: [
                  // Total Transactions Card
                  Expanded(
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${transactions.length}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Total Amount Card
                  Expanded(
                    child: Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final doc = transactions[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final date = data['date&time'] != null
                      ? formatDate((data['date&time'] as Timestamp).toDate())
                      : 'N/A';
                  final amount = data['amount']?.toString() ?? '0';
                  final paymentMethod = data['payment_method'] ?? 'N/A';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.attach_money, color: Colors.white),
                      ),
                      title: Text('\$$amount'),
                      subtitle: Text(paymentMethod),
                      trailing: Text(date),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
