import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idairy/services/auth/auth_gate.dart';
import 'package:idairy/utils/global_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation Controller for controlling the animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade-in animation
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start the animation
    _controller.forward();

    // Navigate to AuthGate after the splash screen duration
    Timer(const Duration(seconds: 3), () {
      Get.offAll(const AuthGate());
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.primary,
      body: FadeTransition(
        opacity: _animation,
        child: const Center(
          child: Text(
            "iDairy App",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
