import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/board_creation/screens/board_creation_screen.dart';
import 'package:bingo_sggw/core/services/deep_link_service.dart';
import 'package:bingo_sggw/features/board_creation/screens/saved_boards_screen.dart';

void main() {
  runApp(const BingoSGGW());
}

class BingoSGGW extends StatefulWidget {
  const BingoSGGW({super.key});

  @override
  State<BingoSGGW> createState() => _BingoSGGWState();
}

class _BingoSGGWState extends State<BingoSGGW> {
  final _deepLinkService = DeepLinkService();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _deepLinkService.initDeepLinks((roomId) {
      _navigateToRoom(roomId);
    });
  }

  void _navigateToRoom(String roomId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
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
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Bingo SGGW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SavedBoardsScreen(),
    );
  }
}