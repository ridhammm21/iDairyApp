// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:idairy/components/my_drawer.dart';
import 'package:idairy/pages/user/order_page.dart';
import 'package:idairy/pages/user/profile_page.dart';
import 'package:idairy/services/auth/auth_service.dart';
import 'package:idairy/utils/global_colors.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 77),
          child: Text("Settings"),
        ),
        backgroundColor: GlobalColors.primary,
        foregroundColor: GlobalColors.textColor,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0), // Add vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSettingItem(
              context,
              title: "Profile",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),

            SizedBox(height: 20.0), // Space between items

            // Order History Section
            _buildSettingItem(
              context,
              title: "Order History",
              icon: Icons.shopping_bag,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),

            Spacer(), // Pushes logout button to the bottom

            // Logout Section
            _buildSettingItem(
              context,
              title: "Logout",
              icon: Icons.logout,
              onTap: logout,
              color: GlobalColors.inversePrimary, // Different color for logout
            ),
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }

  // Widget for building each setting item
  Widget _buildSettingItem(BuildContext context,
      {required String title,
      required IconData icon,
      required Function() onTap,
      Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? GlobalColors.primary, // Use specified color or default
              size: 28.0, // Larger icon size
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color ?? GlobalColors.primary, // Use specified color or default
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
