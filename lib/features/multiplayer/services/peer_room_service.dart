import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:peerdart/peerdart.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';
import 'package:bingo_sggw/features/multiplayer/services/room_service.dart';

class PeerRoomService implements RoomService {
  const PeerRoomService();

  static const _prefix = 'bingo-sggw-';
  static const _timeout = Duration(seconds: 12);

  @override
  Future<RoomSession> hostRoom({
    required String roomId,
    required String hostName,
  }) async {
    const failure = RoomException(
      'Nie udało się utworzyć pokoju. Sprawdź połączenie z internetem.',
    );

    final peer = Peer(id: '$_prefix$roomId');
    final opened = Completer<void>();

    peer.on('open').listen((_) {
      if (!opened.isCompleted) opened.complete();
    });
    peer.on('error').listen((_) {
      if (!opened.isCompleted) opened.completeError(failure);
    });

    try {
      await opened.future.timeout(_timeout, onTimeout: () => throw failure);
    } catch (_) {
      peer.dispose();
      rethrow;
    }

    return _HostSession(peer, hostName);
  }

  @override
  Future<RoomSession> joinRoom({
    required String roomId,
    required String name,
  }) async {
    final failure = RoomException(
      'Nie udało się dołączyć do pokoju $roomId. Sprawdź kod i połączenie z internetem.',
    );

    final peer = Peer();
    final connected = Completer<DataConnection>();

    peer.on('error').listen((_) {
      if (!connected.isCompleted) connected.completeError(failure);
    });
    peer.on('open').listen((_) {
      final conn = peer.connect('$_prefix$roomId');
      conn.on('open').listen((_) {
        if (!connected.isCompleted) connected.complete(conn);
      });
    });

    try {
      final conn =
          await connected.future.timeout(_timeout, onTimeout: () => throw failure);
      return _GuestSession(peer, conn, name);
    } catch (_) {
      peer.dispose();
      rethrow;
    }
  }
}

Map<String, dynamic> _playerToJson(Player player) =>
    {'name': player.name, 'isHost': player.isHost};

class _HostSession implements RoomSession {
  _HostSession(this._peer, String hostName)
      : _host = Player(name: hostName, isHost: true) {
    _peer.on<DataConnection>('connection').listen(_onConnection);
  }

  final Peer _peer;
  final Player _host;
  final _guests = <DataConnection, Player>{};
  late final _players = ValueNotifier<List<Player>>([_host]);
  final _startedBoard = ValueNotifier<BingoBoard?>(null);
  final _closed = ValueNotifier<bool>(false);
  final _checked = ValueNotifier<Set<int>>({});

  @override
  ValueListenable<List<Player>> get players => _players;

  @override
  ValueListenable<BingoBoard?> get startedBoard => _startedBoard;

  @override
  ValueListenable<bool> get closed => _closed;

  @override
  ValueListenable<Set<int>> get checkedTiles => _checked;

  @override
  bool get isHost => true;

  void _onConnection(DataConnection conn) {
    conn.on('data').listen((data) {
      if (data is! Map) return;

      if (data['type'] == 'join') {
        final name = (data['name'] as String? ?? '').trim();
        _guests[conn] = Player(name: name.isEmpty ? 'Gracz' : name);
        _publishPlayers();
      } else if (data['type'] == 'toggle' && data['index'] is int) {
        toggleTile(data['index'] as int);
      }
    });
    conn.on('close').listen((_) {
      if (_guests.remove(conn) != null) _publishPlayers();
    });
  }

  void _publishPlayers() {
    final players = [_host, ..._guests.values];
    _players.value = players;
    _broadcast({
      'type': 'players',
      'players': players.map(_playerToJson).toList(),
    });
  }

  void _broadcast(Map<String, dynamic> message) {
    for (final conn in _guests.keys.toList()) {
      conn.send(message);
    }
  }

  @override
  Future<void> startGame(BingoBoard board) async {
    _broadcast({'type': 'start', 'board': board.toJson()});
  }

  @override
  void toggleTile(int index) {
    final checked = {..._checked.value};
    if (!checked.remove(index)) {
      checked.add(index);
    }
    _setChecked(checked);
  }

  @override
  void resetTiles() => _setChecked({});

  void _setChecked(Set<int> checked) {
    _checked.value = checked;
    _broadcast({'type': 'tiles', 'checked': checked.toList()});
  }

  @override
  void dispose() {
    _peer.dispose();
    _players.dispose();
    _startedBoard.dispose();
    _closed.dispose();
    _checked.dispose();
  }
}

class _GuestSession implements RoomSession {
  _GuestSession(this._peer, this._conn, this._name) {
    _conn.on('data').listen(_onData);
    _conn.on('close').listen((_) {
      if (!_disposed) _closed.value = true;
    });

    _sendJoin();
    _retry = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_joined) {
        _retry?.cancel();
      } else {
        _sendJoin();
      }
    });
  }

  final Peer _peer;
  final DataConnection _conn;
  final String _name;
  late final _players = ValueNotifier<List<Player>>([Player(name: _name)]);
  final _startedBoard = ValueNotifier<BingoBoard?>(null);
  final _closed = ValueNotifier<bool>(false);
  final _checked = ValueNotifier<Set<int>>({});
  Timer? _retry;
  bool _joined = false;
  bool _disposed = false;

  @override
  ValueListenable<List<Player>> get players => _players;

  @override
  ValueListenable<BingoBoard?> get startedBoard => _startedBoard;

  @override
  ValueListenable<bool> get closed => _closed;

  @override
  ValueListenable<Set<int>> get checkedTiles => _checked;

  @override
  bool get isHost => false;

  void _sendJoin() {
    _conn.send({'type': 'join', 'name': _name});
  }

  void _onData(dynamic data) {
    if (_disposed || data is! Map) return;

    switch (data['type']) {
      case 'players':
        _joined = true;
        _players.value = [
          for (final p in data['players'] as List)
            Player(name: p['name'] as String, isHost: p['isHost'] as bool),
        ];
      case 'start':
        _startedBoard.value = BingoBoard.fromJson(
          Map<String, dynamic>.from(data['board'] as Map),
        );
      case 'tiles':
        _checked.value = {
          for (final index in data['checked'] as List) index as int,
        };
    }
  }

  @override
  Future<void> startGame(BingoBoard board) async {
    throw StateError('Tylko host może rozpocząć grę.');
  }

  @override
  void toggleTile(int index) {
    _conn.send({'type': 'toggle', 'index': index});
  }

  @override
  void resetTiles() {
    throw StateError('Tylko host może zresetować planszę.');
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _peer.dispose();
    _players.dispose();
    _startedBoard.dispose();
    _closed.dispose();
    _checked.dispose();
  }
}
