import 'package:flutter/material.dart';
import 'package:idairy/pages/navigation_page.dart';
import 'package:idairy/services/auth/auth_service.dart';
import 'package:idairy/utils/global_colors.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();
    // Optionally, pop all screens and redirect to login page or home
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: GlobalColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // logo
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.local_drink_outlined,
                    size: 40,
                    color: GlobalColors.textColor,
                  ),
                ),
              ),

              // Home
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text("H O M E", style: TextStyle(color: GlobalColors.textColor)),
                  leading: Icon(Icons.home, color: GlobalColors.textColor),
                  onTap: () {
                    // Close the drawer and navigate to the Home screen
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(initialIndex: 0),
                      ),
                    );
                  },
                ),
              ),

              // Cart
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text("C A R T", style: TextStyle(color: GlobalColors.textColor)),
                  leading: Icon(Icons.shopping_cart, color: GlobalColors.textColor),
                  onTap: () {
                    // Close the drawer and navigate to Cart screen
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(initialIndex: 1),
                      ),
                    );
                  },
                ),
              ),

              // Wallet
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text("W A L L E T", style: TextStyle(color: GlobalColors.textColor)),
                  leading: Icon(Icons.account_balance_wallet, color: GlobalColors.textColor),
                  onTap: () {
                    // Close the drawer and navigate to Wallet screen
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(initialIndex: 2),
                      ),
                    );
                  },
                ),
              ),

              // Setting
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: Text("S E T T I N G", style: TextStyle(color: GlobalColors.textColor)),
                  leading: Icon(Icons.settings, color: GlobalColors.textColor),
                  onTap: () {
                    // Close the drawer and navigate to Settings screen
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(initialIndex: 3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: Text("L O G O U T", style: TextStyle(color: GlobalColors.textColor)),
              leading: Icon(Icons.logout, color: GlobalColors.textColor),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
