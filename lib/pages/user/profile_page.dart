import 'package:flutter/material.dart';
import 'package:idairy/services/auth/auth_service.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String email = "Loading...";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? "";
          addressController.text = userDoc['address'] ?? "";
          phoneController.text = userDoc['phoneNumber'] ?? "";
          email = currentUser!.email ?? "No email found"; // Fetching email from FirebaseAuth
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user data')),
      );
    }
  }

  Future<void> _updateUserDetails() async {
    if (currentUser == null) return;

    String phoneNumber = phoneController.text.trim();

    // 🔹 Phone Number Validation
    if (phoneNumber.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phoneNumber': phoneNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors.primary,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Name", nameController, Icons.person, editable: true),
              _buildInfoField("Email", email, Icons.email), // Fixed Email Display
              _buildTextField("Address", addressController, Icons.home, editable: true),
              _buildTextField("Phone Number", phoneController, Icons.phone, editable: true),
              const SizedBox(height: 20.0),

              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateUserDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20.0),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _authService.signOut,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool editable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        enabled: editable,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: value),
        style: const TextStyle(color: Colors.black), // 🔹 Ensuring black text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black), // 🔹 Ensuring label is black
          prefixIcon: Icon(icon, color: Colors.black), // 🔹 Ensuring icon is black
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          disabledBorder: OutlineInputBorder( // 🔹 Ensuring border remains like editable fields
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}
