import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  List<DocumentSnapshot> _orders = [];
  Map<String, bool> _expandedOrders = {}; // Track expanded order sections
  Map<String, Map<String, dynamic>> _userDetails = {}; // Store user details

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from Firestore
  Future<void> _fetchOrders() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      List<DocumentSnapshot> orders = querySnapshot.docs;

      // ✅ Sort so 'Pending' comes first
      orders.sort((a, b) {
        String statusA = a['orderStatus'] ?? 'Pending';
        return statusA == 'Pending' ? -1 : 1;
      });

      setState(() {
        _orders = orders;
        _isLoading = false;
      });

      // Fetch user details for each order
      for (var order in orders) {
        String uid = order['uid'];
        if (!_userDetails.containsKey(uid)) {
          _fetchUserDetails(uid);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: ${e.toString()}')),
      );
    }
  }

  // Fetch user details from Firestore
  Future<void> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        setState(() {
          _userDetails[uid] = userSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user details: ${e.toString()}')),
      );
    }
  }

  // ✅ Update order status in BOTH orders and users collection
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      DocumentSnapshot orderSnapshot = await orderRef.get();
      if (!orderSnapshot.exists) {
        throw 'Order not found';
      }

      String uid = orderSnapshot['uid']; // ✅ Get user's UID

      // ✅ Update main orders collection
      await orderRef.update({'orderStatus': newStatus});

      // ✅ Update order inside user's collection
      DocumentReference userOrderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(orderId);

      await userOrderRef.update({'orderStatus': newStatus});

      // Refresh orders after update
      _fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    var order = _orders[index];
                    var orderId = order.id;
                    var status = order['orderStatus'] ?? 'Pending';
                    var uid = order['uid']; // Fetch user ID
                    var user = _userDetails[uid] ?? {}; // Get user details

                    var itemsMap = order['items'] ?? {};
                    var items = itemsMap is Map ? itemsMap.values.toList() : [];

                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Order ID: $orderId'),
                            subtitle: Text(
                              'Total: ₹${order['totalAmount']} | Status: $status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: status == 'Completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                _expandedOrders[orderId] == true
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandedOrders[orderId] =
                                      !(_expandedOrders[orderId] ?? false);
                                });
                              },
                            ),
                          ),

                          if (_expandedOrders[orderId] == true)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text(
                                    'Ordered Items:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (items.isEmpty)
                                    const Text('No items found',
                                        style: TextStyle(color: Colors.red))
                                  else
                                    Column(
                                      children: items.map<Widget>((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${item['name']}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                'Price per Unit: ₹${item['pricePerUnit']}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                'Quantity: ${item['quantity']}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                'Total Price: ₹${item['totalPrice']}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const Divider(),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                  const SizedBox(height: 10),

                                  // ✅ User Details Section
                                  const Text(
                                    'User Details:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Name: ${user['name'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 16)),
                                  Text('Address: ${user['address'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 16)),
                                  Text('Phone: ${user['phoneNumber'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 16)),

                                  const SizedBox(height: 10),

                                  if (status == 'Pending')
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Complete Order'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        _updateOrderStatus(
                                            orderId, 'Completed');
                                      },
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
