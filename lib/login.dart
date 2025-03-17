import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username == '2315091038' && password == '2315091038') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username atau Password salah!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset('assets/Logo_undiksha_1.png', height: 120),
              ),
              SizedBox(height: 20),
              Text(
                "Koperasi Undiksha",
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              SizedBox(height: 30),
              _buildTextField(usernameController, "Username (NIM)", Icons.person),
              SizedBox(height: 15),
              _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text("Login", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text("Daftar Mbanking", style: GoogleFonts.poppins(color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("Lupa Password?", style: GoogleFonts.poppins(color: Colors.redAccent)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("©2025 Koperasi Undiksha", style: GoogleFonts.poppins(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(fontSize: 16),
    );
  }
}
