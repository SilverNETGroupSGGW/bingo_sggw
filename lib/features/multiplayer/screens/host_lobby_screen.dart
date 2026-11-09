import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';
import 'package:bingo_sggw/features/multiplayer/widgets/players_list.dart';

class HostLobbyScreen extends StatefulWidget {
  final String roomId;
  final String hostName;
  final BingoBoard board;
  final RoomService roomService;

  const HostLobbyScreen({
    super.key,
    required this.roomId,
    required this.hostName,
    required this.board,
    this.roomService = const MockRoomService(),
  });

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  late final Stream<List<Player>> _players;

  @override
  void initState() {
    super.initState();
    _players = widget.roomService.watchPlayers(
      roomId: widget.roomId,
      self: Player(name: widget.hostName, isHost: true),
    );
  }

  void _startGame() {
    final tiles = widget.board.tiles
        .map((t) => BingoTile(id: t.id, text: t.text))
        .toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BingoBoardScreen(
          gridSize: widget.board.size,
          title: widget.board.title,
          initialTiles: tiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final joinUrl = 'bingo://join?room=${widget.roomId}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pokój: ${widget.roomId}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zeskanuj kod w aplikacji lub przez Google Lens, aby dołączyć',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: QrImageView(
                      data: joinUrl,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: PlayersList(stream: _players)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Zacznij grę'),
                    style: FilledButton.styleFrom(
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
