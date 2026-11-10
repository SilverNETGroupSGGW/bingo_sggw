import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';

class MockRoomService implements RoomService {
  final List<String> joiners;

  MockRoomService({this.joiners = const ['Ania', 'Marek', 'Kasia']});

  @override
  Future<RoomSession> hostRoom({
    required String roomId,
    required String hostName,
  }) async {
    return MockRoomSession([Player(name: hostName, isHost: true)], joiners);
  }

  @override
  Future<RoomSession> joinRoom({
    required String roomId,
    required String name,
  }) async {
    return MockRoomSession(
      [const Player(name: 'Prowadzący', isHost: true), Player(name: name)],
      joiners,
      isHost: false,
    );
  }
}

class MockRoomSession implements RoomSession {
  MockRoomSession(
    List<Player> initial,
    List<String> joiners, {
    this.isHost = true,
  }) : _players = ValueNotifier(initial) {
    var index = 0;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (index >= joiners.length) {
        timer.cancel();
        return;
      }
      _players.value = [..._players.value, Player(name: joiners[index++])];
    });
  }

  final ValueNotifier<List<Player>> _players;
  final _startedBoard = ValueNotifier<BingoBoard?>(null);
  final _closed = ValueNotifier<bool>(false);
  final _checked = ValueNotifier<Set<int>>({});
  Timer? _timer;
  BingoBoard? lastStartedBoard;

  @override
  final bool isHost;

  @override
  ValueListenable<List<Player>> get players => _players;

  @override
  ValueListenable<BingoBoard?> get startedBoard => _startedBoard;

  @override
  ValueListenable<bool> get closed => _closed;

  @override
  ValueListenable<Set<int>> get checkedTiles => _checked;

  @override
  Future<void> startGame(BingoBoard board) async {
    lastStartedBoard = board;
  }

  @override
  void toggleTile(int index) {
    final checked = {..._checked.value};
    if (!checked.remove(index)) {
      checked.add(index);
    }
    _checked.value = checked;
  }

  @override
  void resetTiles() {
    _checked.value = {};
  }

  @override
  void dispose() {
    _timer?.cancel();
  }
}

class FailingRoomService implements RoomService {
  @override
  Future<RoomSession> hostRoom({
    required String roomId,
    required String hostName,
  }) async {
    throw const RoomException('Nie udało się utworzyć pokoju.');
  }

  @override
  Future<RoomSession> joinRoom({
    required String roomId,
    required String name,
  }) async {
    throw const RoomException('Nie udało się dołączyć do pokoju.');
  }
}
