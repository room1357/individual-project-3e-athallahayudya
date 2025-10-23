import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Nama Pengguna';
  String _email = 'user@email.com';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('username');
    final storedEmail = prefs.getString('email');

    if (!mounted) return;
    setState(() {
      if (storedUser != null && storedUser.isNotEmpty) _username = storedUser;
      if (storedEmail != null && storedEmail.isNotEmpty) _email = storedEmail;
    });
  }

  Future<void> _editProfile() async {
    // Buat controllers dan formKey di dalam builder agar lifecycle aman
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) {
        final usernameCtrl = TextEditingController(text: _username);
        final emailCtrl = TextEditingController(text: _email);
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Edit Profil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                    final email = v.trim();
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    return emailRegex.hasMatch(email) ? null : 'Format email tidak valid';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, {
                    'username': usernameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    // Setelah dialog tertutup, result di-handle di sini (di luar build scope)
    if (result != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', result['username'] ?? _username);
      await prefs.setString('email', result['email'] ?? _email);

      if (!mounted) return;
      setState(() {
        _username = result['username'] ?? _username;
        _email = result['email'] ?? _email;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil disimpan'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data SharedPreferences

    if (!mounted) return;
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                _username,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                _email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ListTile(
                  leading: Icon(Icons.date_range, color: Colors.blue),
                  title: Text('Tanggal Bergabung'),
                  subtitle: Text('1 Januari 2025'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _editProfile,
                    label: const Text('Edit Profil'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}