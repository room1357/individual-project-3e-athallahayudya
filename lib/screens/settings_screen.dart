import 'package:flutter/material.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Notifikasi
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.blue),
            title: const Text('Aktifkan Notifikasi'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
          const Divider(height: 0),

          // Dark Mode
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.blue),
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (val) {
              setState(() {
                _isDarkMode = val;
              });
            },
          ),
          const Divider(height: 0),

          // Tentang Aplikasi
          /* ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Tentang Aplikasi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(height: 0),*/

          // Kembali ke Home
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.red),
            title: const Text('Kembali'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
