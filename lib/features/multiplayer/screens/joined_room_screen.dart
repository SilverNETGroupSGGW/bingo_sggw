import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';
import 'package:bingo_sggw/features/multiplayer/widgets/players_list.dart';

class JoinedRoomScreen extends StatefulWidget {
  final String roomId;
  final RoomService roomService;

  const JoinedRoomScreen({
    super.key,
    required this.roomId,
    this.roomService = const MockRoomService(),
  });

  @override
  State<JoinedRoomScreen> createState() => _JoinedRoomScreenState();
}

class _JoinedRoomScreenState extends State<JoinedRoomScreen> {
  final _nameController = TextEditingController();
  Stream<List<Player>>? _players;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _join() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _players = widget.roomService.watchPlayers(
        roomId: widget.roomId,
        self: Player(name: name),
      );
    });
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
                maxLength: 20,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _join(),
                decoration: const InputDecoration(
                  labelText: 'Jak się nazywasz?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _join,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Dołącz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLobby(Stream<List<Player>> players) {
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
              Expanded(child: PlayersList(stream: players)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = _players;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pokój: ${widget.roomId}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: players == null ? _buildNameForm() : _buildLobby(players),
      ),
    );
  }
}
