import 'package:flutter/material.dart';
import 'package:idairy/pages/admin/screens/view_product.dart';
import 'package:idairy/pages/admin/screens/insights_page.dart';
import 'package:idairy/pages/admin/screens/orders_page.dart'; // Import Orders Page
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

  final List<Widget> _pages = [
    const ViewProduct(), // Product Page
    const OrdersPage(),  // Orders Page
    const InsightsPage(), // Insights Page
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

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Products',
            icon: Icon(Icons.pages),
          ),
          BottomNavigationBarItem(
            label: 'Orders',
            icon: Icon(Icons.shopping_cart), // Orders icon
          ),
          BottomNavigationBarItem(
            label: 'Insights',
            icon: Icon(Icons.insights),
          ),
        ],
      ),
    );
  }
}
