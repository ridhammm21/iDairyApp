import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController imageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final CollectionReference products = FirebaseFirestore.instance.collection('products');

  @override
  void initState() {
    super.initState();
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
          'imageUrl': imageController.text,
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
    imageController.clear();
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(labelText: 'Image URL', border: const OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an image URL';
                        }
                        Uri? uri = Uri.tryParse(value);
                        if (uri == null || !(uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
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
