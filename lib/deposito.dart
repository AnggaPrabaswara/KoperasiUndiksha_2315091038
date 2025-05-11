import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'home.dart'; 
import 'profile_provider.dart';

class DepositoPage extends StatefulWidget {
  @override
  _DepositoPageState createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceAccountController = TextEditingController();
  final TextEditingController _interestReceiverController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  double _interestRate = 5.0;
  int _duration = 6;
  String _depositType = 'Rupiah';
  String _rolloverOption = 'Tidak';
  bool _agreeTerms = false;
  bool _isLoading = false;

  Future<void> _submitDeposito() async {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPassword = prefs.getString('password');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Verifikasi Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Masukkan password Anda untuk konfirmasi.", style: GoogleFonts.poppins()),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _passwordController.clear();
              },
              child: Text("Batal", style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == savedPassword) {
                  Navigator.pop(context);
                  _passwordController.clear();
                  _proceedWithDeposito();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Password salah. Silakan coba lagi.", style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Konfirmasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silakan setujui syarat & ketentuan terlebih dahulu.", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedWithDeposito() {
    final amount = double.parse(_amountController.text);
    final totalInterest = amount * (_interestRate / 100) * (_duration / 12);
    final totalAmount = amount + totalInterest;

    setState(() => _isLoading = true);

    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);

      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.reduceSaldo(amount.toInt());

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 10),
              Text("Deposito Berhasil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            "Deposito sebesar Rp. ${amount.toStringAsFixed(2)} telah berhasil.\n\n"
            "Jenis: $_depositType\n"
            "Tenor: $_duration bulan\n"
            "Suku Bunga: $_interestRate%\n"
            "Perpanjangan: $_rolloverOption\n\n"
            "Total Saldo Akhir: Rp. ${totalAmount.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                _formKey.currentState!.reset();
                setState(() {
                  _agreeTerms = false;
                });

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              child: Text("Kembali ke Beranda", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Deposito Berjangka",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Jumlah Deposito"),
                _buildTextField(_amountController, "Masukkan jumlah deposito", FontAwesomeIcons.moneyBillTrendUp),
                SizedBox(height: 15),
                _buildLabel("Tenor Deposito"),
                _buildDropdown<int>(
                  _duration,
                  [1, 3, 6, 12, 24, 36],
                  (val) => setState(() => _duration = val!),
                  (val) => "$val bulan",
                  FontAwesomeIcons.calendarAlt,
                ),
                SizedBox(height: 15),
                _buildLabel("Jenis Deposito"),
                _buildDropdown<String>(
                  _depositType,
                  ['Rupiah', 'Valas'],
                  (val) => setState(() => _depositType = val!),
                  (val) => val,
                  FontAwesomeIcons.coins,
                ),
                SizedBox(height: 15),
                _buildLabel("Perpanjangan (ARO)"),
                _buildDropdown<String>(
                  _rolloverOption,
                  ['Tidak', 'Pokok Saja', 'Pokok + Bunga'],
                  (val) => setState(() => _rolloverOption = val!),
                  (val) => val,
                  FontAwesomeIcons.syncAlt,
                ),
                SizedBox(height: 15),
                _buildLabel("Rekening Sumber Dana"),
                _buildTextField(_sourceAccountController, "Contoh: 1234567890", FontAwesomeIcons.wallet),
                SizedBox(height: 15),
                _buildLabel("Rekening Penerima Bunga"),
                _buildTextField(_interestReceiverController, "Contoh: 0987654321", FontAwesomeIcons.solidMoneyBill1),
                SizedBox(height: 20),
                CheckboxListTile(
                  value: _agreeTerms,
                  onChanged: (val) => setState(() => _agreeTerms = val!),
                  title: Text("Saya menyetujui syarat dan ketentuan", style: GoogleFonts.poppins()),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitDeposito,
                    icon: _isLoading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : FaIcon(FontAwesomeIcons.piggyBank, color: Colors.white),
                    label: Text(
                      _isLoading ? "Memproses..." : "Simpan Deposito",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500));
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
    );
  }

  Widget _buildDropdown<T>(T value, List<T> items, void Function(T?) onChanged, String Function(T) label, IconData icon) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((val) => DropdownMenuItem(value: val, child: Text(label(val), style: GoogleFonts.poppins()))).toList(),
      onChanged: onChanged,
    );
  }
}