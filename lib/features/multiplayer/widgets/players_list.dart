import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';

class PlayersList extends StatelessWidget {
  final Stream<List<Player>> stream;

  const PlayersList({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Player>>(
      stream: stream,
      builder: (context, snapshot) {
        final players = snapshot.data ?? const <Player>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gracze (${players.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        player.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(player.name),
                    trailing: player.isHost
                        ? const Chip(
                            label: Text('Host'),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
