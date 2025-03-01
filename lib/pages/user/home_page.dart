import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idairy/components/my_drawer.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference products = FirebaseFirestore.instance.collection('products');

  // Function to add product to cart in local storage
  Future<void> _addToCart(Map<String, dynamic> product) async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, dynamic> cartItems = {}; // Stores productId as key

  // Retrieve existing cart items
  List<String>? storedCart = prefs.getStringList('cart');
  if (storedCart != null) {
    for (var item in storedCart) {
      var parts = item.split(':');
      if (parts.length == 4) {
        cartItems[parts[0]] = {
          'name': parts[1],
          'quantity': int.parse(parts[2]),
          'price': double.parse(parts[3])
        };
      }
    }
  }

  // Use productId to avoid duplication issues
  String productId = product['productId'];

  if (cartItems.containsKey(productId)) {
    cartItems[productId]['quantity'] += 1;
  } else {
    cartItems[productId] = {
      'name': product['name'],
      'quantity': 1,
      'price': product['price'],
    };
  }

  // Save updated cart to SharedPreferences
  await prefs.setStringList(
    'cart',
    cartItems.entries.map((e) => '${e.key}:${e.value['name']}:${e.value['quantity']}:${e.value['price']}').toList(),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${product['name']} added to cart!'),
      duration: const Duration(seconds: 1),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 77),
          child: Text("Home"),
        ),
        backgroundColor: GlobalColors.primary,
        foregroundColor: GlobalColors.textColor,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: products.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No products available"));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display 2 items per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4, // Control height of grid items
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
  DocumentSnapshot product = snapshot.data!.docs[index];
  Map<String, dynamic> data = product.data()! as Map<String, dynamic>;

  // Check if stock is available
  bool isOutOfStock = data['stock'] == 0;

  return GestureDetector(
    onTap: () => isOutOfStock ? null : _addToCart(data), // Disable tap if out of stock
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: Colors.grey,
                ), // Placeholder for product image
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              '₹${data['price'].toString()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (isOutOfStock)
              Text(
                'Out of Stock',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

            );
          },
        ),
      ),
    );
  }
}
