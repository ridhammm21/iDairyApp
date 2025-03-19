import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // ✅ For sending data to Google Sheets

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final CollectionReference products = FirebaseFirestore.instance.collection('products');

  @override
  void initState() {
    super.initState();
    _handleMonthlyReset();
  }

  /// ✅ Function to handle sales tracking and reset
  Future<void> _handleMonthlyReset() async {
    DateTime now = DateTime.now();
    int lastDay = DateTime(now.year, now.month + 1, 0).day;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if it's the last day of the month and hasn't been recorded yet
    if (now.day == lastDay && prefs.getInt('lastProcessedMonth') != now.month) {
      await _storeSalesData();
      prefs.setInt('lastProcessedMonth', now.month);
    }

    // Reset `sold` count on the 1st day of the new month
    if (now.day == 1) {
      await _resetSoldCount();
    }
  }

  /// ✅ Store the last day's total sales in Google Sheets
  Future<void> _storeSalesData() async {
    QuerySnapshot snapshot = await products.get();
    for (var doc in snapshot.docs) {
      int sold = doc['sold'] ?? 0;
      if (sold > 0) {
        _sendSoldDataToGoogleSheets(doc['name'], sold);
      }
    }
  }

  /// ✅ Reset sold count to 0 on the 1st day of the new month
  Future<void> _resetSoldCount() async {
    QuerySnapshot snapshot = await products.get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'sold': 0});
    }
  }

  /// ✅ Send data to Google Sheets (Replace with your script URL)
  Future<void> _sendSoldDataToGoogleSheets(String productName, int sold) async {
    String url = "https://script.google.com/macros/s/AKfycbz20CrJk55tAo022GNoQclNRX8vJWRDiBZ2UOEd_ro79OTwun-JKuyAdHmu2j-uXlkQ/exec";
    try {
      await http.post(Uri.parse(url), body: {
        'productName': productName,
        'sold': sold.toString(),
      });
      debugPrint("✅ Sent $sold units of $productName to Google Sheets");
    } catch (e) {
      debugPrint("❌ Error sending data: $e");
    }
  }

  /// ✅ Function to add a new product
  Future<void> addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        var productRef = await products.add({
          'name': nameController.text,
          'price': double.parse(priceController.text),
          'description': descriptionController.text,
          'stock': int.parse(stockController.text),
          'sold': 0,
        });

        await productRef.update({'productId': productRef.id});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        clearFields();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add product!')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Clear form fields
  void clearFields() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    stockController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Product Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Product Name', border: const OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Please enter the product name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price', border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value!) == null ? 'Please enter a valid number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description', border: const OutlineInputBorder()),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stockController,
                      decoration: InputDecoration(labelText: 'Stock Quantity', border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value!) == null ? 'Please enter a valid number' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Add Product', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
