import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bingo_sggw/core/utils/room_code.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/multiplayer/services/peer_room_service.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';
import 'package:bingo_sggw/features/multiplayer/widgets/players_list.dart';

class HostLobbyScreen extends StatefulWidget {
  final String hostName;
  final BingoBoard board;
  final RoomService roomService;

  const HostLobbyScreen({
    super.key,
    required this.hostName,
    required this.board,
    this.roomService = const PeerRoomService(),
  });

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  RoomSession? _session;
  String? _roomId;
  String? _error;
  bool _handedOver = false;

  @override
  void initState() {
    super.initState();
    _openRoom();
  }

  @override
  void dispose() {
    if (!_handedOver) {
      _session?.dispose();
    }
    super.dispose();
  }

  Future<void> _openRoom() async {
    final roomId = generateRoomCode();

    try {
      final session = await widget.roomService.hostRoom(
        roomId: roomId,
        hostName: widget.hostName,
      );

      if (!mounted) {
        session.dispose();
        return;
      }

      setState(() {
        _roomId = roomId;
        _session = session;
      });
    } on RoomException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    }
  }

  void _retry() {
    setState(() => _error = null);
    _openRoom();
  }

  Future<void> _startGame() async {
    final session = _session!;
    final tiles = widget.board.tiles
        .map((t) => BingoTile(id: t.id, text: t.text))
        .toList();
    final board = BingoBoard(
      id: widget.board.id,
      title: widget.board.title,
      size: widget.board.size,
      tiles: tiles,
    );

    await session.startGame(board);
    if (!mounted) return;

    _handedOver = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BingoBoardScreen(
          gridSize: board.size,
          title: board.title,
          initialTiles: board.tiles,
          session: session,
        ),
      ),
    );
  }

  Widget _buildStatus() {
    final error = _error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (error == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Tworzę pokój...'),
            ] else ...[
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _retry,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLobby(RoomSession session, String roomId) {
    final theme = Theme.of(context);
    final joinUrl = 'bingo://join?room=$roomId';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pokój: $roomId',
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
              Expanded(child: PlayersList(players: session.players)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final roomId = _roomId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: session == null || roomId == null
            ? _buildStatus()
            : _buildLobby(session, roomId),
      ),
    );
  }
}
