import 'package:flutter/foundation.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';

class RoomException implements Exception {
  final String message;

  const RoomException(this.message);

  @override
  String toString() => message;
}

abstract class RoomSession {
  ValueListenable<List<Player>> get players;
  ValueListenable<BingoBoard?> get startedBoard;
  ValueListenable<bool> get closed;

  Future<void> startGame(BingoBoard board);
  void dispose();
}

abstract class RoomService {
  Future<RoomSession> hostRoom({
    required String roomId,
    required String hostName,
  });

  Future<RoomSession> joinRoom({
    required String roomId,
    required String name,
  });
}
