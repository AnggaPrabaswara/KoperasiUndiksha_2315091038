import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan provider
import 'profile_provider.dart'; // Import ProfileProvider
import 'login.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  // Impor intl untuk inisialisasi
import 'package:intl/date_symbol_data_local.dart';  // Pastikan ini diimpor

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal dengan locale Indonesia
  await initializeDateFormatting('id_ID', null); // Pastikan ini ada di awal

  // Ambil status login dari SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileProvider(), // Menggunakan ProfileProvider untuk aplikasi
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koperasi Undiksha',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      // Memeriksa status login dan menampilkan halaman yang sesuai
      home: isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        // Tambahkan rute lainnya sesuai kebutuhan
      },
    );
  }
}
