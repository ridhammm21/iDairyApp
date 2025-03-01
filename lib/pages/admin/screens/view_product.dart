import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:idairy/pages/admin/screens/update_screen.dart';
import 'package:idairy/pages/admin/screens/add_products.dart'; // Import the AddProductPage

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  final CollectionReference products = FirebaseFirestore.instance.collection('products');
  String searchQuery = '';  // Variable to store search query
  String sortBy = 'name'; // Sort by name by default
  bool ascending = true; // Ascending order by default

  // Function to delete a product with confirmation dialog
  Future<void> _deleteProduct(String productId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await products.doc(productId).delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Function to filter and sort products
  List<DocumentSnapshot> _filterAndSortProducts(List<DocumentSnapshot> productsList) {
    // Filter products by search query
    List<DocumentSnapshot> filteredProducts = productsList.where((product) {
      Map<String, dynamic> data = product.data()! as Map<String, dynamic>;
      String name = data['name'].toLowerCase();
      String description = data['description'].toLowerCase();
      return name.contains(searchQuery.toLowerCase()) || description.contains(searchQuery.toLowerCase());
    }).toList();

    // Sort products based on the selected sort option
    filteredProducts.sort((a, b) {
      Map<String, dynamic> dataA = a.data()! as Map<String, dynamic>;
      Map<String, dynamic> dataB = b.data()! as Map<String, dynamic>;

      if (sortBy == 'price') {
        double priceA = dataA['price'].toDouble();
        double priceB = dataB['price'].toDouble();
        return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      } else if (sortBy == 'stock') {
        int stockA = dataA['stock'];
        int stockB = dataB['stock'];
        return ascending ? stockA.compareTo(stockB) : stockB.compareTo(stockA);
      } else { // Sort by name
        String nameA = dataA['name'];
        String nameB = dataB['name'];
        return ascending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      }
    });

    return filteredProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'), // Title for the Products page
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),

          // Sorting options (Dropdown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'stock', child: Text('Stock')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                  },
                ),
              ],
            ),
          ),

          // Displaying products
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: products.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter and sort the product list
                List<DocumentSnapshot> filteredAndSortedProducts = _filterAndSortProducts(snapshot.data!.docs);

                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: filteredAndSortedProducts.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.shopping_cart, color: Colors.white),
                        ),
                        title: Text(
                          data['name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ₹${data['price']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            // Change this part to handle "Out of Stock" display
                            Text(
                              data['stock'] == 0 ? 'Out of Stock' : 'Stock: ${data['stock']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: data['stock'] == 0 ? Colors.red : Colors.black, // Red color for "Out of Stock"
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Description: ${data['description']}', // Added product description
                              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProductScreen(
                                      productId: document.id,
                                      initialProductData: data,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteProduct(document.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for adding new products
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Add Product page
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddProductPage(); // Your Add Product screen
          }));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green, // Customize the button color
        tooltip: 'Add Product',
      ),
    );
  }
}
