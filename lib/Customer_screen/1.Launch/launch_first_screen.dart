import 'dart:async';
import 'package:flutter/material.dart';
import 'launch_welcome_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LaunchWelcomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5CB58),
        child: Center(
          child: Image.asset(
            'assets/images/nimah_logo1.png',
            width: 800,
            height: 800,
          ),
        ),
      ),
    );
  }
}