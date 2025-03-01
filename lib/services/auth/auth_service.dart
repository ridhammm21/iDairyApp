import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        // Save user info only if they don't exist
        await _firestore.collection("users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
            'wallet': 0,
            'address': '', // Default empty
            'phoneNumber': '' // Default empty
          },
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign up
  Future<UserCredential> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Save user info with empty address and phone number
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'wallet': 0,
          'address': '', // Default empty
          'phoneNumber': '' // Default empty
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Update user profile (Address & Phone Number)
  Future<void> updateUserProfile(String uid, String address, String phoneNumber) async {
    try {
      await _firestore.collection("users").doc(uid).update({
        'address': address,
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
