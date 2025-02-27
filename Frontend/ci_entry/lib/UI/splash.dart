import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ci_entry/UI/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, 
        child: Center(
          child: Image.asset(
            'assets/images/splash_logo.gif',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
