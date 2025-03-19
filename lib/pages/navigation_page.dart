import 'package:flutter/material.dart';
import 'package:idairy/pages/user/cart_page.dart';
import 'package:idairy/pages/user/home_page.dart';
import 'package:idairy/pages/user/setting_page.dart';
import 'package:idairy/pages/user/wallet_page.dart';
import 'package:idairy/utils/global_colors.dart';

class NavigationPage extends StatefulWidget {
  final int initialIndex; // Add initialIndex to control the screen

  const NavigationPage({super.key, this.initialIndex = 0}); // Default is 0 (Home)

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex;

  final List<Widget> _screens = const [
    HomePage(),
    CartPage(),
    WalletPage(),
    SettingPage(),
  ];

  _NavigationPageState() : _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index from the widget
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavbarItem(Icons.home_outlined, 'Home', 0),
            buildNavbarItem(Icons.shopping_cart_outlined, 'Cart', 1),
            buildNavbarItem(Icons.account_balance_wallet_outlined, 'Wallet', 2),
            buildNavbarItem(Icons.settings_outlined, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  Widget buildNavbarItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? GlobalColors.tertiary : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? GlobalColors.tertiary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
