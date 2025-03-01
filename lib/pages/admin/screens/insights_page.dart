import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  List<SalesData> _salesData = [];

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

      setState(() {
        _totalOrders = totalOrders;
        _totalRevenue = totalRevenue;
        _salesData = dailyRevenue.entries.map((e) => SalesData(e.key, e.value)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Insights')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  Expanded(child: _buildSalesTrendChart()),
                ],
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
            Text(value, style: TextStyle(fontSize: 36, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Sales Trend'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<SalesData, String>>[
        LineSeries<SalesData, String>(
          name: 'Revenue',
          dataSource: _salesData,
          xValueMapper: (SalesData sales, _) => sales.date,
          yValueMapper: (SalesData sales, _) => sales.revenue,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}

class SalesData {
  final String date;
  final double revenue;
  SalesData(this.date, this.revenue);
}
