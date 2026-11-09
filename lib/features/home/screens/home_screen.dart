import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/board_creation/screens/board_creation_screen.dart';
import 'package:bingo_sggw/features/board_creation/screens/saved_boards_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/joined_room_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/scan_qr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSavedBoards(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SavedBoardsScreen()),
    );
  }

  void _createBoard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BoardCreationScreen()),
    );
  }

  Future<void> _joinRoom(BuildContext context) async {
    final roomId = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const ScanQrScreen()),
    );

    if (roomId != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => JoinedRoomScreen(roomId: roomId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
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
                    onPressed: () => _openSavedBoards(context),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Moje plansze'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => _createBoard(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Nowa plansza'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _joinRoom(context),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Dołącz do pokoju'),
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
    );
  }
}
