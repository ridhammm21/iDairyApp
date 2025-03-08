import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForecastPage extends StatefulWidget {
  const ForecastPage({Key? key}) : super(key: key);

  @override
  _ForecastPageState createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  List<Map<String, String>> products = [];
  String? selectedProduct;
  List<Map<String, dynamic>> forecastData = [];
  bool hasError = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// Fetch product list from Firebase
  Future<void> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      List<Map<String, String>> tempProducts = snapshot.docs.map((doc) {
        final name = doc["name"] as String? ?? "Unknown";
        return {"name": name};
      }).toList();

      setState(() {
        products = tempProducts;
      });
    } catch (e) {
      print("❌ Error fetching products: $e");
    }
  }

  /// Fetch GID from Google Sheets for the selected product
  Future<String?> fetchGID(String productName) async {
    try {
      const sheetUrl =
          "https://docs.google.com/spreadsheets/d/1MCrucUxUJXQQwpQ-thS2yVbVe8vn2xIVM8s7WatKBXE/gviz/tq?tqx=out:csv&gid=0";
      final response = await http.get(Uri.parse(sheetUrl));

      if (response.statusCode == 200) {
        List<String> rows = response.body.split("\n");

        for (int i = 1; i < rows.length; i++) {
          List<String> columns = rows[i].split(",");

          if (columns.length >= 2) {
            String sheetName = columns[0].trim().replaceAll('"', '');
            String gid = columns[1].trim().replaceAll('"', '');

            if (sheetName.toLowerCase().trim() == productName.toLowerCase().trim()) {
              return gid;
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching GID: $e");
    }
    return null;
  }

  /// Fetch forecast and actual sales data
  Future<void> fetchForecast() async {
    if (selectedProduct == null) return;

    setState(() {
      isLoading = true;
      hasError = false;
      forecastData = [];
    });

    String? gid = await fetchGID(selectedProduct!);
    if (gid == null) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    try {
      // Fetch last 6 months of actual sales data
      String sheetUrl =
          "https://docs.google.com/spreadsheets/d/1MCrucUxUJXQQwpQ-thS2yVbVe8vn2xIVM8s7WatKBXE/gviz/tq?tqx=out:csv&gid=$gid";
      final sheetResponse = await http.get(Uri.parse(sheetUrl));

      List<Map<String, dynamic>> actualData = [];
      if (sheetResponse.statusCode == 200) {
        List<String> rows = sheetResponse.body.split("\n");
        for (int i = 1; i < rows.length; i++) {
          List<String> columns = rows[i].split(",");
          if (columns.length >= 2) {
            actualData.add({
              "date": columns[0].trim().replaceAll('"', ''),
              "value": double.tryParse(columns[1].trim().replaceAll('"', '')) ?? 0
            });
          }
        }
        if (actualData.length > 6) {
          actualData = actualData.sublist(actualData.length - 6);
        }
      }

      // Fetch forecasted values from API
      String apiUrl = "https://idairyapi-production.up.railway.app/forecast?gid=$gid";
      final apiResponse = await http.get(Uri.parse(apiUrl));

      List<Map<String, dynamic>> forecastList = [];
      if (apiResponse.statusCode == 200) {
        final jsonData = json.decode(apiResponse.body);
        final forecast = jsonData["data"]["forecast"];

        if (forecast != null) {
          forecastList = forecast.map<Map<String, dynamic>>((item) {
            return {
              "date": item["date"],
              "value": item["forecast"],
            };
          }).toList();
        }
      }

      // Combine actual and forecasted data
      setState(() {
        forecastData = [...actualData, ...forecastList];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demand Forecast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dropdown to Select Product
            products.isEmpty
                ? const Center(child: Text("No products available"))
                : DropdownButton<String>(
                    value: selectedProduct,
                    hint: const Text("Select a product"),
                    isExpanded: true,
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product["name"],
                        child: Text(product["name"]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = value;
                      });
                    },
                  ),
            const SizedBox(height: 20),

            // Fetch Forecast Button
            ElevatedButton(
              onPressed: fetchForecast,
              child: const Text("Get Forecast"),
            ),

            const SizedBox(height: 20),

            // Display Forecast Data in Table
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(
                          child: Text(
                            "❌ Failed to fetch data",
                            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        )
                      : forecastData.isEmpty
                          ? const Center(child: Text("No data available"))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: DataTable(
                                  border: TableBorder.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "Date",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Value",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  rows: forecastData.map((data) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(data["date"].toString(),
                                              style: const TextStyle(fontSize: 14)),
                                        ),
                                        DataCell(
                                          Text(data["value"].toString(),
                                              style: const TextStyle(fontSize: 14)),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
