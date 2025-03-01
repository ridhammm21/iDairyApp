import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idairy/components/my_drawer.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, Map<String, dynamic>> cartItems = {}; // Stores productId, name, quantity, and price
  Map<String, double> productPrices = {}; // Stores item prices
  double totalAmount = 0.0;
  double walletBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    setState(() => isLoading = true);
    try {
      await _loadCartItems();
      await _fetchProductPrices();
      await _fetchWalletBalance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedCart = prefs.getStringList('cart');
    if (storedCart != null) {
      cartItems.clear();
      for (var item in storedCart) {
        var parts = item.split(':');
        if (parts.length == 4) {
          cartItems[parts[0]] = {
            'name': parts[1],
            'quantity': int.parse(parts[2]),
            'price': double.parse(parts[3]),
          };
        }
      }
      _calculateTotalAmount();
    }
  }

  Future<void> _fetchProductPrices() async {
    final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');
    final querySnapshot = await productsCollection.get();

    productPrices.clear();
    for (var doc in querySnapshot.docs) {
      productPrices[doc.id] = doc['price']?.toDouble() ?? 0.0;
    }
    _calculateTotalAmount();
  }

  Future<void> _fetchWalletBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      walletBalance = userDoc['wallet']?.toDouble() ?? 0.0;
    }
  }

  double _calculateDeliveryCharges() {
    return totalAmount > 500.0 ? 0.0 : 50.0; // Delivery free if more than ₹500
  }

  void _calculateTotalAmount() {
    totalAmount = 0.0;
    cartItems.forEach((item, details) {
      totalAmount += details['price'] * details['quantity'];
    });
  }

  Future<void> _increaseQuantity(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    cartItems[itemId]!['quantity'] = (cartItems[itemId]!['quantity'] ?? 0) + 1;

    await prefs.setStringList(
      'cart',
      cartItems.entries.map((e) => '${e.key}:${e.value['name']}:${e.value['quantity']}:${e.value['price']}').toList(),
    );
    _calculateTotalAmount();
    setState(() {});
  }

  Future<void> _removeFromCart(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cartItems[itemId]!['quantity'] > 1) {
      cartItems[itemId]!['quantity'] = cartItems[itemId]!['quantity'] - 1;
    } else {
      cartItems.remove(itemId);
    }

    await prefs.setStringList(
      'cart',
      cartItems.entries.map((e) => '${e.key}:${e.value['name']}:${e.value['quantity']}:${e.value['price']}').toList(),
    );
    _calculateTotalAmount();
    setState(() {});
  }

  Future<void> _deleteFromCart(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    cartItems.remove(itemId);

    await prefs.setStringList(
      'cart',
      cartItems.entries.map((e) => '${e.key}:${e.value['name']}:${e.value['quantity']}:${e.value['price']}').toList(),
    );
    _calculateTotalAmount();
    setState(() {});
  }

  Future<void> _slideToPay() async {
  if (cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your cart is empty! Add items before proceeding.')),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in!')),
    );
    return;
  }

  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists || userDoc['address'] == null || userDoc['address'].toString().trim().isEmpty || 
        userDoc['phoneNumber'] == null || userDoc['phoneNumber'].toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please update your profile with an address and phone number before proceeding!')),
      );
      return;
    }

    if (totalAmount + _calculateDeliveryCharges() > walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient wallet balance!')),
      );
      return;
    }

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;

    final orderDetails = {
      'items': cartItems.map((key, value) => MapEntry(key, {
            'name': value['name'],
            'quantity': value['quantity'],
            'pricePerUnit': value['price'],
            'totalPrice': value['price'] * value['quantity'],
          })),
      'subtotal': totalAmount,
      'deliveryCharges': _calculateDeliveryCharges(),
      'totalAmount': totalAmount + _calculateDeliveryCharges(),
      'timestamp': FieldValue.serverTimestamp(),
      'uid': user.uid,
      'orderId': orderId,
      'orderStatus': 'Pending',
    };

    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('orders').doc(orderId).set(orderDetails);
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderDetails);

    for (var item in cartItems.entries) {
      String productId = item.key;
      int quantityPurchased = item.value['quantity'];

      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'stock': FieldValue.increment(-quantityPurchased),
        'sold': FieldValue.increment(quantityPurchased),
      });
    }

    setState(() {
      walletBalance -= totalAmount + _calculateDeliveryCharges();
      cartItems.clear();
      totalAmount = 0.0;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'wallet': walletBalance});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful! Order placed as Pending.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error processing payment: $e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 85),
          child: Text("Cart"),
        ),
        backgroundColor: GlobalColors.primary,
        foregroundColor: GlobalColors.textColor,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(child: Text("Your cart is empty"))
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            String item = cartItems.keys.elementAt(index);
                            int quantity = cartItems[item]?['quantity'] ?? 0;
                            double price = cartItems[item]?['price'] ?? 0.0;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                title: Text(cartItems[item]!['name']),
                                subtitle: Text(
                                  'Quantity: $quantity\nPrice: ₹${(price * quantity).toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _increaseQuantity(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _removeFromCart(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteFromCart(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      _buildBillDetails(),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onHorizontalDragEnd: (details) => _slideToPay(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          decoration: BoxDecoration(
                            color: GlobalColors.primary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Center(
                            child: Text(
                              'Slide to Pay',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBillDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Details',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal:'),
            Text('₹${totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Charges:'),
            Text('₹${_calculateDeliveryCharges().toStringAsFixed(2)}'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '₹${(totalAmount + _calculateDeliveryCharges()).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Text('Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}'),
      ],
    );
  }
}
