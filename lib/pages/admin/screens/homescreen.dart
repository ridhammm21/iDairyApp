import 'package:flutter/material.dart';
import 'package:idairy/pages/admin/screens/view_product.dart';
import 'package:idairy/pages/admin/screens/insights_page.dart';
import 'package:idairy/pages/admin/screens/orders_page.dart';
import 'package:idairy/pages/admin/screens/forecast.dart'; // ✅ Import Forecast Page
import 'package:idairy/services/auth/auth_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  int _currentIndex = 0;

  // ✅ Added ForecastPage() to the list
  final List<Widget> _pages = [
    const ViewProduct(),  // Index 0
    const OrdersPage(),   // Index 1
    const InsightsPage(), // Index 2
    const ForecastPage(), // Index 3 ✅ Fixing the error
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: _pages[_currentIndex], // ✅ Fix: Now has correct index range

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // ✅ Prevents icons from disappearing
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Products',
            icon: Icon(Icons.shopping_bag),
          ),
          BottomNavigationBarItem(
            label: 'Orders',
            icon: Icon(Icons.receipt_long),
          ),
          BottomNavigationBarItem(
            label: 'Insights',
            icon: Icon(Icons.analytics),
          ),
          BottomNavigationBarItem(
            label: 'Forecast',
            icon: Icon(Icons.show_chart), // ✅ Icon for Forecast Page
          ),
        ],
      ),
    );
  }
}
