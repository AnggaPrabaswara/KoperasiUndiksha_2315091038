import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'profile_provider.dart';

class MutasiPage extends StatelessWidget {
  const MutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Mutasi'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Riwayat Transaksi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Daftar Mutasi
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  List<Transaksi> transaksiList = profileProvider.transaksiList;

                  if (transaksiList.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada transaksi.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = transaksiList[index];
                      return _buildTransaksiCard(transaksi);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan card transaksi
  Widget _buildTransaksiCard(Transaksi transaksi) {
    final formattedDate = DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(transaksi.tanggal);
    final formattedNominal = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(transaksi.nominal);

    return Card(
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Keterangan transaksi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),      
              ],
            ),
            // Nominal
            Text(
              formattedNominal,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
