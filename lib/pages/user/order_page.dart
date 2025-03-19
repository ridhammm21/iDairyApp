import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:intl/intl.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('dd/MM/yy hh:mm a').format(dateTime);
}

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchOrderHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders');

    final querySnapshot = await ordersRef.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final itemsMap = data['items'] as Map<String, dynamic>;
      final itemsList = itemsMap.entries.map((entry) {
        final item = entry.value as Map<String, dynamic>;
        return {
          'name': item['name'],
          'quantity': item['quantity'],
          'totalPrice': item['totalPrice'] ?? item['price'] * item['quantity'],
        };
      }).toList();

      return {
        'orderId': doc.id,
        'timestamp': data['timestamp'],
        'items': itemsList,
        'totalAmount': data['totalAmount'],
        'orderStatus': data['orderStatus'] ?? 'Pending',
      };
    }).toList()
      ..sort((a, b) {
        if (a['orderStatus'] == 'Pending' && b['orderStatus'] != 'Pending') {
          return -1;
        } else if (a['orderStatus'] != 'Pending' && b['orderStatus'] == 'Pending') {
          return 1;
        } else {
          return (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: GlobalColors.primary,
        foregroundColor: GlobalColors.textColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No order history found."));
          } else {
            final orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = order['items'] as List<dynamic>;
                final status = order['orderStatus'];

                Color cardColor = status == 'Cancelled'
                    ? Colors.red[100]!
                    : (status == 'Pending' ? Colors.amber[100]! : Colors.green[100]!);

                Color statusColor = status == 'Cancelled'
                    ? Colors.red
                    : (status == 'Pending' ? Colors.orange : Colors.green);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID: ${order['orderId']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text("Date: ${formatDate(order['timestamp'])}"),
                        const SizedBox(height: 8.0),
                        const Text("Items:"),
                        ...items.map((item) => Text(
                              "- ${item['name']} x${item['quantity']} (₹${item['totalPrice'].toStringAsFixed(2)})",
                            )),
                        const SizedBox(height: 8.0),
                        Text("Total Amount: ₹${order['totalAmount'].toStringAsFixed(2)}"),
                        const SizedBox(height: 8.0),
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
