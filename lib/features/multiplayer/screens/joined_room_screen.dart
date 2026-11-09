import 'package:flutter/material.dart';

/// Ekran po dołączeniu do pokoju (przez QR lub link).
/// Na razie tylko placeholder – dalej będzie lobby z planszą od hosta.
class JoinedRoomScreen extends StatelessWidget {
  final String roomId;

  const JoinedRoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokój: $roomId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              'Dołączono do pokoju $roomId!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Oczekiwanie na przesłanie planszy od Hosta...'),
          ],
        ),
      ),
    );
  }
}
