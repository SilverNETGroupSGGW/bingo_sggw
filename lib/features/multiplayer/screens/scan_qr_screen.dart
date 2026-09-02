import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawUrl = barcode.rawValue;
      if (rawUrl != null && rawUrl.contains('room=')) {
        setState(() {
          _isScanned = true;
        });

        final uri = Uri.parse(rawUrl);
        final roomId = uri.queryParameters['room'];

        if (roomId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dołączono do pokoju: $roomId')),
          );
          
          Navigator.of(context).pop(roomId);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zeskanuj Kod Pokoju')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}