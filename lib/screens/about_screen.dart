import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // final String photo =
  //     "https://raw.githubusercontent.com/anil-s-yadav/stream24news_crm/refs/heads/main/lib/assets/news_app_logos/aboutus_logo.png";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        title: const Text("About us"),
        backgroundColor: const Color(0xFF202C33),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      "lib/images/logo.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Stream24 News",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text("Version: 1.0.0 (1)",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"))
        ],
      ),
    );
  }
}
