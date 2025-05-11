import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'profile_provider.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller?.scannedDataStream.listen((scanData) {
      if (!_isScanned) {
        _isScanned = true;
        controller?.pauseCamera();

        _handlePayment(scanData.code);
      }
    });
  }

  void _handlePayment(String? data) {
    if (data == null) return;

    // Format QR: "Bayar|NamaToko|Jumlah"
    final parts = data.split('|');
    if (parts.length != 3 || parts[0] != 'Bayar') {
      _showErrorDialog("QR Code tidak valid.");
      return;
    }

    final namaToko = parts[1];
    final jumlah = int.tryParse(parts[2]) ?? 0;

    if (jumlah <= 0) {
      _showErrorDialog("Jumlah tidak valid.");
      return;
    }

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (provider.saldoInt < jumlah) {
      _showErrorDialog("Saldo tidak mencukupi.");
      return;
    }

    // Kurangi saldo & catat transaksi
    provider.reduceSaldo(jumlah);

    _showSuccessDialog("Pembayaran ke $namaToko sebesar Rp$jumlah berhasil.");
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanned = false;
                controller?.resumeCamera();
              });
            },
            child: const Text('Coba Lagi'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Pembayaran'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }
}
