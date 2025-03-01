
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:idairy/pages/admin/screens/homescreen.dart';
import 'package:idairy/pages/navigation_page.dart';
import 'package:idairy/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user logged in
          if(snapshot.hasData){
            if(snapshot.data!.email == "admin@gmail.com") {
              return const AdminHome();
            }
            return const NavigationPage();
          }
          //user not logged in
          else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}