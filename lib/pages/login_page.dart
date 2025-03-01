// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:idairy/components/my_button.dart';
import 'package:idairy/components/my_textfield.dart';
import 'package:idairy/services/auth/auth_service.dart';
import 'package:idairy/utils/global_colors.dart';

class LoginPage extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void Function()? onTap;

  LoginPage({
    super.key,
    required this.onTap,
  });

  void login(BuildContext context) async{
    //auth service
    final authService = AuthService();

    //try login
    try{
      await authService.signInWithEmailPassword(_emailController.text, _passwordController.text);
    }
    //catch error
    catch(e) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.textColor, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.local_drink,
              size: 60,
              color: GlobalColors.primary,
            ),
            const SizedBox(height: 50),
            //welcome
            Text(
              "Welcome back, you've been missed!",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            //email
            MyTextField(
              hintText: 'Email',
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            //password
            MyTextField(
              hintText: 'Password',
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 25),
            //login button
            MyButton(
              text: "Login",
              onTap: () => login(context),
            ),
            const SizedBox(height: 25),
            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(
                    color: GlobalColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GlobalColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
          ],
          ),
      ),
    );
  }
}