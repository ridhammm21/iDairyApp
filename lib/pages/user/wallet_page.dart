import 'package:flutter/material.dart';
import 'package:idairy/components/my_drawer.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:idairy/widget/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  TextEditingController amountcontroller = TextEditingController();
  double walletBalance = 0.0; // Initialize wallet balance

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance(); // Fetch balance when the widget is initialized
  }

  // Fetch wallet balance from Firestore
  Future<void> _fetchWalletBalance() async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          walletBalance = userDoc['wallet'].toDouble(); // Set the wallet balance
        });
      }
    }
  }

  // Show confirmation dialog before updating the wallet balance
  Future<void> _showConfirmationDialog(double amountToAdd) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Add Money'),
          content: Text('Are you sure you want to add \$${amountToAdd.toStringAsFixed(2)} to your wallet?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _updateWalletBalance(amountToAdd); // Proceed to add money
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Update the wallet balance in Firestore
  Future<void> _updateWalletBalance(double amountToAdd) async {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      await userDocRef.update({
        'wallet': FieldValue.increment(amountToAdd), // Increment the wallet amount
      });
      _fetchWalletBalance(); // Refresh the wallet balance after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 77),
          child: Text("Wallet"),
        ),
        backgroundColor: GlobalColors.primary,
        foregroundColor: GlobalColors.textColor,
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
              child: Row(
                children: [
                  Image.asset(
                    "images/wallet.png",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    width: 40.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Wallet",
                        style: AppWidget.LightTextFeildStyle(),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "\$" + walletBalance.toStringAsFixed(2), // Display wallet balance
                        style: AppWidget.boldTextFeildStyle(),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Add money",
                style: AppWidget.semiBoldTextFeildStyle(),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _showConfirmationDialog(100); // Show confirmation for adding 100
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "100",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showConfirmationDialog(500); // Show confirmation for adding 500
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "500",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showConfirmationDialog(1000); // Show confirmation for adding 1000
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "1000",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showConfirmationDialog(2000); // Show confirmation for adding 2000
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE9E2E2)),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "\$" + "2000",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
            GestureDetector(
              onTap: () {
                openEdit();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: GlobalColors.primary,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    "Add Money",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      drawer: MyDrawer(),
    );
  }

  Future<void> makePayment(String amount) async {
    double? amountToAdd = double.tryParse(amount); // Parse the entered amount
    if (amountToAdd != null && amountToAdd > 0) {
      _showConfirmationDialog(amountToAdd); // Show confirmation for custom amount
    }
  }

  Future openEdit() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.cancel)),
                      SizedBox(
                        width: 60.0,
                      ),
                      Center(
                        child: Text(
                          "Add Money",
                          style: TextStyle(
                            color: GlobalColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("Amount"),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: 2.0),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: amountcontroller,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Enter Amount'),
                      keyboardType: TextInputType.number, // Allow only numbers
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        makePayment(amountcontroller.text);
                      },
                      child: Container(
                        width: 100,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: GlobalColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(
                          "Pay",
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
