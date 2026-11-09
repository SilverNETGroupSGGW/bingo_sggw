import 'package:flutter/material.dart';
import 'package:bingo_sggw/core/services/deep_link_service.dart';
import 'package:bingo_sggw/features/board_creation/screens/saved_boards_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/joined_room_screen.dart';

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
          builder: (context) => JoinedRoomScreen(roomId: roomId),
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