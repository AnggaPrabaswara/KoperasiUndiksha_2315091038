import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Model Transaksi
class Transaksi {
 // Transfer, Deposito, Pembayaran, Pinjaman
  final int nominal;

  final DateTime tanggal;
  
  Transaksi({

    required this.nominal,

    required this.tanggal,
  });
}

class ProfileProvider extends ChangeNotifier {
  String _userName = '';
  int _saldo = 10288000; // Saldo awal dalam format integer
  final List<Transaksi> _transaksiList = []; // Menyimpan riwayat transaksi

  String get userName => _userName;
  String get saldo => 'Rp. ${NumberFormat("#,###", "id_ID").format(_saldo)}';
  List<Transaksi> get transaksiList => List.unmodifiable(_transaksiList); // Immutable List

  // Fungsi untuk menambahkan saldo dan mencatat sebagai transaksi jika diperlukan
  void addSaldo(int amount, {String? jenis, String? keterangan}) {
    _saldo += amount; // Mengupdate saldo


      _transaksiList.add(
        Transaksi(

          nominal: amount,
    
          tanggal: DateTime.now(),
        ),
      );
    

    notifyListeners();
  }

  // Fungsi untuk mengurangi saldo dan mencatat sebagai transaksi jika diperlukan
  void reduceSaldo(int amount, {String? jenis, String? keterangan}) {
    _saldo -= amount; // Mengupdate saldo

    
      _transaksiList.add(
        Transaksi(
      
          nominal: amount,
      
          tanggal: DateTime.now(),
        ),
      );
    

    notifyListeners();
  }

  // Fungsi untuk mendapatkan saldo dalam bentuk angka
  int get saldoInt => _saldo;

  // Fungsi untuk menyimpan password menggunakan SharedPreferences
  Future<void> savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  // Fungsi untuk mengambil password dari SharedPreferences
  Future<String?> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  // Fungsi untuk set username setelah login
  void setUserName(String username) {
    _userName = username;
    notifyListeners();
  }

  // Fungsi manual untuk menambah transaksi dari luar (misal: halaman pinjaman, dll)
  void addTransaksi(Transaksi transaksi) {
    _transaksiList.add(transaksi);
    notifyListeners();
  }
}
