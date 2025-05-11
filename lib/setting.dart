import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Akun',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Nama Pengguna'),
            subtitle: Text(profileProvider.userName.isEmpty ? 'Belum diatur' : profileProvider.userName),
            trailing: const Icon(Icons.edit),
            onTap: () {
              // Tampilkan dialog edit nama pengguna
              _showEditNameDialog(context, profileProvider);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Ubah Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigasi atau tampilkan modal ubah password
              _showEditPasswordDialog(context, profileProvider);
            },
          ),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            'Lainnya',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pusat Bantuan'),
            onTap: () {
              // Tambahkan navigasi ke halaman bantuan
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () {
              // Tambahkan dialog atau navigasi tentang aplikasi
              showAboutDialog(
                context: context,
                applicationName: 'Koperasi Undiksha',
                applicationVersion: '1.0.0',
                children: [const Text('Aplikasi m-Banking Koperasi Undiksha.')],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar'),
            textColor: Colors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, ProfileProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Pengguna'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan nama baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setUserName(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditPasswordDialog(BuildContext context, ProfileProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Masukkan password baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.savePassword(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
