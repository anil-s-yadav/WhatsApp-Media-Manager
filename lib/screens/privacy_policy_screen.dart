import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF202C33),
      ),
      backgroundColor: const Color(0xFF111B21),
      body: const Center(
        child: Text(
          'Privacy policy details will be shown here.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
