import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/howtouse.dart';
import 'utils/providers/download_provider.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_policy_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DownloadProvider())],
      child: MaterialApp(
        title: 'WhatsApp Downloader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF25D366), // WhatsApp green
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/downloads': (context) => const MyDownloadsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/about': (context) => const AboutScreen(),
          '/privacy': (context) => const PrivacyPolicyScreen(),
          '/howto': (context) => const HowToUseScreen(),
        },
      ),
    );
  }
}
