import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/multiplayer/models/player.dart';

import 'support/mock_room_service.dart';

List<BingoTile> tiles() => [
      for (int i = 0; i < 9; i++) BingoTile(id: '$i', text: 'Pole $i'),
    ];

MockRoomSession session({required bool isHost}) => MockRoomSession(
      [const Player(name: 'Ola', isHost: true)],
      const [],
      isHost: isHost,
    );

Future<void> pumpGame(WidgetTester tester, MockRoomSession session) {
  return tester.pumpWidget(
    MaterialApp(
      home: BingoBoardScreen(
        gridSize: 3,
        title: 'Test',
        initialTiles: tiles(),
        session: session,
      ),
    ),
  );
}

void main() {
  testWidgets('kliknięcie kafelka idzie przez sesję i zaznacza go',
      (WidgetTester tester) async {
    final s = session(isHost: true);
    await pumpGame(tester, s);

    await tester.tap(find.text('Pole 0'));
    await tester.pump();

    expect(s.checkedTiles.value, {0});
    expect(find.text('1 / 9'), findsOneWidget);
  });

  testWidgets('zmiana stanu z sesji (inny gracz) odświeża planszę',
      (WidgetTester tester) async {
    final s = session(isHost: false);
    await pumpGame(tester, s);

    s.toggleTile(1);
    s.toggleTile(2);
    await tester.pump();

    expect(find.text('2 / 9'), findsOneWidget);
  });

  testWidgets('wspólna linia daje bingo', (WidgetTester tester) async {
    final s = session(isHost: true);
    await pumpGame(tester, s);

    s.toggleTile(0);
    s.toggleTile(1);
    s.toggleTile(2);
    await tester.pump();

    expect(find.text('🎉 BINGO! 🎉'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('host widzi przycisk resetu', (WidgetTester tester) async {
    await pumpGame(tester, session(isHost: true));

    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
  });

  testWidgets('gość nie widzi przycisku resetu', (WidgetTester tester) async {
    await pumpGame(tester, session(isHost: false));

    expect(find.byIcon(Icons.restart_alt), findsNothing);
  });
}
