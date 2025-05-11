import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'profile_provider.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  _PeminjamanPageState createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController tenorController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController jaminanController = TextEditingController();

  String selectedJenisPinjaman = 'Personal';
  bool isSetuju = false;

  late ProfileProvider profileProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileProvider = Provider.of<ProfileProvider>(context);
  }

  final NumberFormat rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

  Future<void> _submitPeminjaman() async {
    if (!isSetuju) {
      _showSnackBar('Anda harus menyetujui syarat dan ketentuan!');
      return;
    }

    String nominalText = nominalController.text.trim();
    String tenorText = tenorController.text.trim();

    if (nominalText.isEmpty || int.tryParse(nominalText) == null || int.parse(nominalText) <= 0) {
      _showSnackBar('Masukkan nominal pinjaman yang valid!');
      return;
    }

    if (tenorText.isEmpty || int.tryParse(tenorText) == null || int.parse(tenorText) <= 0) {
      _showSnackBar('Masukkan tenor yang valid!');
      return;
    }

    int nominal = int.parse(nominalText);
    int tenor = int.parse(tenorText);

    _showPasswordDialog(nominal, tenor);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  Future<void> _showPasswordDialog(int nominal, int tenor) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Masukkan password Anda", style: GoogleFonts.poppins()),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String enteredPassword = passwordController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                String? savedPassword = prefs.getString('password');

                if (enteredPassword == savedPassword) {
                  profileProvider.addSaldo(
                    nominal,
                    jenis: 'Pinjaman',
                    keterangan: 'Pinjaman $selectedJenisPinjaman, tenor $tenor bulan',
                  );
                  Navigator.pop(context);
                  _resetForm();
                  _showSnackBar('Peminjaman berhasil! Tenor: $tenor bulan');
                } else {
                  _showSnackBar('Password salah!');
                }
              },
              child: Text("Konfirmasi", style: GoogleFonts.poppins(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    passwordController.clear();
    nominalController.clear();
    tenorController.clear();
    jaminanController.clear();
    setState(() {
      isSetuju = false;
      selectedJenisPinjaman = 'Personal';
    });
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = true}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      style: GoogleFonts.poppins(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bunga = 0.05;
    final int nominal = int.tryParse(nominalController.text) ?? 0;
    final int tenor = int.tryParse(tenorController.text) ?? 0;
    final double totalCicilan = nominal + (nominal * bunga * tenor);

    return Scaffold(
      appBar: AppBar(
        title: Text("Pengajuan Pinjaman", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, ${profileProvider.userName}", style: GoogleFonts.poppins(fontSize: 18)),
            Text("Saldo Anda: ${profileProvider.saldo}", style: GoogleFonts.poppins()),

            SizedBox(height: 25),
            _buildTextField(nominalController, "Nominal Pinjaman (Rp)", Icons.money),
            SizedBox(height: 15),
            _buildTextField(tenorController, "Tenor (bulan)", Icons.access_time),
            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedJenisPinjaman,
              items: ["Personal", "Usaha", "Pendidikan"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => selectedJenisPinjaman = value!),
              decoration: InputDecoration(
                labelText: "Jenis Pinjaman",
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),
            SizedBox(height: 15),

            _buildTextField(jaminanController, "Deskripsi Jaminan (opsional)", Icons.security, isNumber: false),
            SizedBox(height: 15),

            Text("Suku Bunga: 5% per bulan", style: GoogleFonts.poppins()),

            CheckboxListTile(
              value: isSetuju,
              onChanged: (value) => setState(() => isSetuju = value ?? false),
              title: Text("Saya menyetujui syarat dan ketentuan yang berlaku", style: GoogleFonts.poppins()),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ringkasan Pinjaman", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Jumlah Pinjaman: ${rupiahFormat.format(nominal)}", style: GoogleFonts.poppins()),
                    Text("Tenor: $tenor bulan", style: GoogleFonts.poppins()),
                    Text("Bunga: 5%", style: GoogleFonts.poppins()),
                    Text("Total Cicilan: ${rupiahFormat.format(totalCicilan)}", style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _submitPeminjaman,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Ajukan Pinjaman", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
