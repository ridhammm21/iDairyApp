import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  String _topSellingProduct = '';
  String _leastSellingProduct = '';

  @override
  void initState() {
    super.initState();
    _fetchInsightsData();
  }

  Future<void> _fetchInsightsData() async {
    try {
      DateTime startOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
      DateTime endOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: endOfMonth)
          .get();

      Map<String, double> dailyRevenue = {};
      int totalOrders = querySnapshot.docs.length;
      double totalRevenue = 0.0;

      for (var doc in querySnapshot.docs) {
        DateTime orderDate = (doc['timestamp'] as Timestamp).toDate();
        String day = '${orderDate.day}/${_selectedMonth}';
        double amount = doc['totalAmount'];

        dailyRevenue[day] = (dailyRevenue[day] ?? 0) + amount;
        totalRevenue += amount;
      }

      // Fetch product sales data from the 'products' collection
      Map<String, int> productSales = await _fetchProductSales();

      // Sort products by sold quantity
      if (productSales.isNotEmpty) {
        var sortedProducts = productSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));  // Sort by sold quantity in descending order

        _topSellingProduct = sortedProducts.first.key;
        _leastSellingProduct = sortedProducts.last.key;
      }

      setState(() {
        _totalOrders = totalOrders;
        _totalRevenue = totalRevenue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Please try again later.')),
      );
    }
  }

  Future<Map<String, int>> _fetchProductSales() async {
    try {
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').get();

      Map<String, int> productSales = {};
      for (var productDoc in productSnapshot.docs) {
        String productName = productDoc['name'];
        int soldQty = productDoc['sold'] ?? 0;

        productSales[productName] = soldQty;
      }
      return productSales;
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<int>(
                          value: _selectedMonth,
                          items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}'))),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value!;
                              _isLoading = true;
                            });
                            _fetchInsightsData();
                          },
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: List.generate(10, (index) {
                            int year = DateTime.now().year - 5 + index;
                            return DropdownMenuItem(value: year, child: Text('$year'));
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                              _isLoading = true;
                            });
                            _fetchInsightsData();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard('Total Orders for ${_selectedMonth}/${_selectedYear}', '$_totalOrders', Colors.blueAccent),
                    const SizedBox(height: 20),
                    _buildCard('Total Revenue for ${_selectedMonth}/${_selectedYear}', '₹${_totalRevenue.toStringAsFixed(2)}', Colors.green),
                    const SizedBox(height: 20),
                    _buildCard('Top Selling Product', _topSellingProduct, Colors.orange),
                    const SizedBox(height: 20),
                    _buildCard('Least Selling Product', _leastSellingProduct, Colors.red),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color valueColor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, color: valueColor)),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  final String date;
  final double revenue;
  SalesData(this.date, this.revenue);
}
