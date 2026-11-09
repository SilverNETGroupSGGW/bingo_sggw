import 'package:bingo_sggw/features/multiplayer/models/player.dart';

abstract class RoomService {
  Stream<List<Player>> watchPlayers({
    required String roomId,
    required Player self,
  });
}

class MockRoomService implements RoomService {
  const MockRoomService();

  @override
  Stream<List<Player>> watchPlayers({
    required String roomId,
    required Player self,
  }) async* {
    final players = self.isHost
        ? [self]
        : [const Player(name: 'Prowadzący', isHost: true), self];
    yield List.of(players);

    for (final name in ['Ania', 'Marek', 'Kasia']) {
      await Future.delayed(const Duration(seconds: 2));
      players.add(Player(name: name));
      yield List.of(players);
    }
  }
}
