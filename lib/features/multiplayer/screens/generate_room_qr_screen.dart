import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateRoomQrScreen extends StatelessWidget {
  final String roomId;

  const GenerateRoomQrScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final String joinUrl = 'bingo://join?room=$roomId';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kod Pokoju'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pokój: $roomId',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Zeskanuj kod w aplikacji lub przez Google Lens, aby dołączyć',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              QrImageView(
                data: joinUrl,
                version: QrVersions.auto,
                size: 260.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Przejście do lobby
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('PRZEJDŹ DO LOBBY'),
              )
            ],
          ),
        ),
      ),
    );
  }
}