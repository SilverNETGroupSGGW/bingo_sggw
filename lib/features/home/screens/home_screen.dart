import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/board_creation/screens/board_creation_screen.dart';
import 'package:bingo_sggw/features/board_creation/screens/saved_boards_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/joined_room_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/scan_qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _openSavedBoards() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SavedBoardsScreen()),
    );
  }

  Future<void> _createBoard() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BoardCreationScreen()),
    );

    if (saved == true && mounted) {
      _openSavedBoards();
    }
  }

  void _joinWithCode() {
    final roomId = _codeController.text.trim().toUpperCase();
    if (roomId.isEmpty) return;

    _openRoom(roomId);
  }

  Future<void> _scanQr() async {
    final roomId = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const ScanQrScreen()),
    );

    if (roomId != null && mounted) {
      _openRoom(roomId);
    }
  }

  void _openRoom(String roomId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JoinedRoomScreen(roomId: roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 96,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bingo SGGW',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton.icon(
                      onPressed: _openSavedBoards,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Moje plansze'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _createBoard,
                      icon: const Icon(Icons.add),
                      label: const Text('Nowa plansza'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _joinWithCode(),
                      decoration: InputDecoration(
                        labelText: 'Kod pokoju',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.meeting_room_outlined),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Dołącz do pokoju',
                          onPressed: _joinWithCode,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _scanQr,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Zeskanuj kod QR'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
