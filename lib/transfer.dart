import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;

  void _submitTransfer() async {
    if (_formKey.currentState!.validate()) {
      _showPasswordVerificationPopup();
    }
  }

  Future<void> _showPasswordVerificationPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password') ?? '';
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Verifikasi Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
            child: Text("Batal", style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text == savedPassword) {
                Navigator.pop(context);
                _processTransfer();
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password salah!", style: GoogleFonts.poppins()), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Konfirmasi", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _processTransfer() async {
    setState(() => _isLoading = true);

    // Tampilkan loading dialog
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
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 16),
              Text("Memproses transfer...", style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ),
    );

    // Simulasi delay proses transfer
    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context); // Tutup loading popup
    setState(() => _isLoading = false);

    // Kurangi saldo menggunakan provider
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'\D'), '')) ?? 0;
    provider.reduceSaldo(amount);

    // Tampilkan dialog sukses
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Transfer Berhasil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Rp. ${_amountController.text} telah dikirim ke ${_accountController.text}.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            child: Text("Tutup", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              _accountController.clear();
              _amountController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.indigo.shade900),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.indigo),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Masukkan $label',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: validator,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text("Transfer Dana", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 15,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Nomor Rekening Tujuan',
                        icon: Icons.credit_card,
                        controller: _accountController,
                        validator: (val) => val == null || val.length < 10 ? 'Minimal 10 digit' : null,
                      ),
                      _buildInputField(
                        label: 'Jumlah Transfer',
                        icon: Icons.attach_money,
                        controller: _amountController,
                        validator: (val) {
                          final amount = double.tryParse(val ?? '');
                          if (val == null || val.isEmpty) return 'Jumlah harus diisi';
                          if (amount == null || amount <= 0) return 'Harus lebih dari 0';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            backgroundColor: Colors.indigo,
                            elevation: 10,
                          ),
                          onPressed: _isLoading ? null : _submitTransfer,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Kirim Dana", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
