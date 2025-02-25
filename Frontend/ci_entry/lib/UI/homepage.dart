import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, $username")),
      body: Center(
        child: Text(
          "You have successfully logged in!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
