import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Impor provider
import 'profile_provider.dart'; // Impor ProfileProvider Anda

class PembayaranPage extends StatefulWidget {
  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {"icon": FontAwesomeIcons.bolt, "label": "Listrik"},
    {"icon": FontAwesomeIcons.wifi, "label": "Internet"},
    {"icon": FontAwesomeIcons.mobileAlt, "label": "Pulsa"},
    {"icon": FontAwesomeIcons.droplet, "label": "PDAM"},
    {"icon": FontAwesomeIcons.tv, "label": "TV Kabel"},
    {"icon": FontAwesomeIcons.book, "label": "Pendidikan"},
  ];

  void _submitPayment() {
    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap pilih kategori dan masukkan jumlah pembayaran"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ambil jumlah pembayaran dari controller dan konversi ke integer
    int amount = int.tryParse(_amountController.text) ?? 0;

    // Validasi jumlah pembayaran
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Jumlah pembayaran tidak valid"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _verifyPassword(amount); // Tampilkan popup verifikasi password
  }

  Future<void> _verifyPassword(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password') ?? '';
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Password"),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Masukkan Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text == savedPassword) {
                Navigator.pop(context);
                _showLoadingAndSuccessPopup(amount); // Proses loading dan popup sukses
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password salah!"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Konfirmasi"),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoadingAndSuccessPopup(int amount) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(height: 16),
              Text("Memproses pembayaran...", style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ),
    );

    // Simulate delay for payment processing
    await Future.delayed(Duration(seconds: 2));

    // Close loading dialog
    Navigator.pop(context);

    // Menambahkan transaksi ke riwayat dengan provider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.reduceSaldo(amount, jenis: _selectedCategory, keterangan: 'Pembayaran $_selectedCategory');

    // Show success popup
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pembayaran Berhasil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Rp. ${_amountController.text} untuk $_selectedCategory telah dibayarkan.", style: GoogleFonts.poppins()),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _amountController.clear();
              setState(() {
                _selectedCategory = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Tutup", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pembayaran"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pilih Kategori Pembayaran:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((category) {
                bool isSelected = category['label'] == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['label'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(category['icon'], color: isSelected ? Colors.white : Colors.blue.shade700),
                        SizedBox(width: 8),
                        Text(category['label'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text("Masukkan Jumlah Pembayaran:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Rp. 0",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade700),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Bayar Sekarang", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
