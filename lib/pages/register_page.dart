// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:idairy/components/my_button.dart';
import 'package:idairy/components/my_textfield.dart';
import 'package:idairy/services/auth/auth_service.dart';
import 'package:idairy/utils/global_colors.dart';


class RegisterPage extends StatelessWidget {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  void Function()? onTap;
  
  RegisterPage({
    super.key,
    required this.onTap,
  });

  void register(BuildContext context) async{
    //get auth service
    final _auth = AuthService();

    //password match
    if(_passwordController.text ==_confirmpasswordController.text)
    {
      try{
        _auth.signUpWithEmailPassword(_nameController.text, _emailController.text, _passwordController.text);
      }
      catch (e){
        showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
      }
    }

    //password don't match
    else{
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text("Password don't match"),
        )
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
              hintText: 'Name',
              obscureText: false,
              controller: _nameController,
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            //confirm password
            MyTextField(
              hintText: 'Confirm Password',
              obscureText: true,
              controller: _confirmpasswordController,
            ),
            const SizedBox(height: 25),
            //login button
            MyButton(
              text: "Register",
              onTap: () => register(context),
            ),
            const SizedBox(height: 25),
            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have account? ",
                  style: TextStyle(
                    color: GlobalColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login Now",
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