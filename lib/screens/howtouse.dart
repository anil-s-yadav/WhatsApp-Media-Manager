import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F5EC),
      appBar: AppBar(
        title: const Text('How to Use'),
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Use WhatsApp Media Manager',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '1. Grant Permissions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- On first launch, allow the app to access storage, audio, and video. This is required to display WhatsApp media.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. Browse Media:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- You can view all your WhatsApp images, videos, audio, documents, and statuses in organized tabs.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. Save Media to Downloads:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- Tap on any media file to view it.\n'
                '- You can then tap the download icon to save it to your device\'s Downloads folder.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Save WhatsApp Status:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- Go to the "Status" tab to view the latest WhatsApp status images and videos.\n'
                '- Tap on any status to preview and save it.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. Search & Filter:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- Use the search bar to find specific media by name.\n'
                '- Filter media by category using tabs (Images, Videos, Audio, Documents, etc).',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Enjoy managing your WhatsApp media with ease!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
