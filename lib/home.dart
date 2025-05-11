import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'ceksaldo.dart';
import 'transfer.dart';
import 'deposito.dart';
import 'pembayaran.dart';
import 'profile.dart';
import 'profile_provider.dart';
import 'Peminjaman.dart';
import 'mutasi.dart'; 
import 'setting.dart';
import 'scanqr.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        title: Center(
          child: Text(
            "Menu Utama",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProfileSection(profileProvider),
          SizedBox(height: 20),
          Expanded(child: _buildMenuGrid(context)),
          _buildHelpDeskSection(),
          _buildBottomMenu(context),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
          boxShadow: [
            BoxShadow(color: Colors.blue.shade300, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage('assets/angga genre.jpg'),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ida Bagus Angga Prabaswara", // Menampilkan namamu
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Saldo: ${profileProvider.saldo}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    List<Map<String, dynamic>> menuItems = [
      {"icon": FontAwesomeIcons.wallet, "label": "Cek Saldo", "page": CekSaldoPage()},
      {"icon": FontAwesomeIcons.exchangeAlt, "label": "Transfer", "page": TransferPage()},
      {"icon": FontAwesomeIcons.piggyBank, "label": "Deposito", "page": DepositoPage()},
      {"icon": FontAwesomeIcons.moneyBillWave, "label": "Pembayaran", "page": PembayaranPage()},
      {"icon": FontAwesomeIcons.handHoldingUsd, "label": "Pinjaman", "page": PeminjamanPage()},
      {"icon": FontAwesomeIcons.receipt, "label": "Mutasi", "page": MutasiPage()},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: menuItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemBuilder: (context, index) {
          return _buildMenuItem(
            menuItems[index]["icon"],
            menuItems[index]["label"],
            () {
              if (menuItems[index]["page"] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => menuItems[index]["page"]),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.blue.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.blue.shade100, blurRadius: 5, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 40, color: Colors.blue.shade700),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpDeskSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.blue.shade100, blurRadius: 5, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.phoneAlt, size: 24, color: Colors.blue.shade700),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Butuh Bantuan?",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "0887-3195-039",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.blue.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomIcon(FontAwesomeIcons.cog, "Setting", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingPage()),
          );
        }),

// ...
          _buildBottomIcon(FontAwesomeIcons.qrcode, "Scan QR", () {
           Navigator.push(
           context,
          MaterialPageRoute(builder: (context) => const ScanQRPage()),
         );
        }),

          _buildBottomIcon(FontAwesomeIcons.user, "Profile", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          FaIcon(icon, size: 30, color: Colors.white),
          SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
