import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/multiplayer/services/peer_room_service.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';
import 'package:bingo_sggw/features/multiplayer/widgets/players_list.dart';

class JoinedRoomScreen extends StatefulWidget {
  final String roomId;
  final RoomService roomService;

  const JoinedRoomScreen({
    super.key,
    required this.roomId,
    this.roomService = const PeerRoomService(),
  });

  @override
  State<JoinedRoomScreen> createState() => _JoinedRoomScreenState();
}

class _JoinedRoomScreenState extends State<JoinedRoomScreen> {
  final _nameController = TextEditingController();
  RoomSession? _session;
  bool _connecting = false;
  String? _error;
  bool _handedOver = false;

  @override
  void dispose() {
    _nameController.dispose();
    _detach();
    if (!_handedOver) {
      _session?.dispose();
    }
    super.dispose();
  }

  void _detach() {
    _session?.startedBoard.removeListener(_onStarted);
    _session?.closed.removeListener(_onClosed);
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _connecting) return;

    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      final session = await widget.roomService.joinRoom(
        roomId: widget.roomId,
        name: name,
      );

      if (!mounted) {
        session.dispose();
        return;
      }

      session.startedBoard.addListener(_onStarted);
      session.closed.addListener(_onClosed);
      setState(() {
        _session = session;
        _connecting = false;
      });
    } on RoomException catch (e) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = e.message;
        });
      }
    }
  }

  void _onStarted() {
    final session = _session;
    final board = session?.startedBoard.value;
    if (session == null || board == null || _handedOver) return;

    _handedOver = true;
    _detach();

    final tiles = board.tiles
        .map((t) => BingoTile(id: t.id, text: t.text))
        .toList();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BingoBoardScreen(
          gridSize: board.size,
          title: board.title,
          initialTiles: tiles,
          session: session,
        ),
      ),
    );
  }

  void _onClosed() {
    if (_handedOver || !(_session?.closed.value ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Host zamknął pokój')),
    );
    Navigator.of(context).pop();
  }

  Widget _buildNameForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.wifi, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                'Dołączasz do pokoju ${widget.roomId}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                autofocus: true,
                enabled: !_connecting,
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _join(),
                decoration: const InputDecoration(
                  labelText: 'Jak się nazywasz?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _connecting ? null : _join,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _connecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Dołącz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLobby(RoomSession session) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Czekamy na start gry...',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Host rozpocznie grę, gdy wszyscy dołączą',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 24),
              Expanded(child: PlayersList(players: session.players)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pokój: ${widget.roomId}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: session == null ? _buildNameForm() : _buildLobby(session),
      ),
    );
  }
}
