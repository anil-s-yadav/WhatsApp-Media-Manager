import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF202C33),
      ),
      backgroundColor: const Color(0xFF111B21),
      body: const Center(
        child: Text(
          'About us information will be shown here.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
