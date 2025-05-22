import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showSentFiles = false;
  bool _showPrivateFiles = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showSentFiles = prefs.getBool('show_sent_files') ?? false;
      _showPrivateFiles = prefs.getBool('show_private_files') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_sent_files', _showSentFiles);
    await prefs.setBool('show_private_files', _showPrivateFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF202C33),
      ),
      backgroundColor: const Color(0xFF111B21),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Show Sent Files',
                style: TextStyle(color: Colors.white)),
            value: _showSentFiles,
            onChanged: (value) {
              setState(() {
                _showSentFiles = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Show Private Files',
                style: TextStyle(color: Colors.white)),
            value: _showPrivateFiles,
            onChanged: (value) {
              setState(() {
                _showPrivateFiles = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }
}
