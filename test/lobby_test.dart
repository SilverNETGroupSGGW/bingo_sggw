import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/host_lobby_screen.dart';
import 'package:bingo_sggw/features/multiplayer/screens/joined_room_screen.dart';

import 'support/mock_room_service.dart';

BingoBoard testBoard() => BingoBoard(
      id: '1',
      title: 'Plansza testowa',
      size: 3,
      tiles: [
        for (int i = 0; i < 9; i++) BingoTile(id: '$i', text: 'Pole $i'),
      ],
    );

void main() {
  testWidgets('gość wpisuje nick i widzi lobby z listą graczy',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JoinedRoomScreen(roomId: 'ABC123', roomService: MockRoomService()),
      ),
    );

    expect(find.text('Dołączasz do pokoju ABC123'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Kuba');
    await tester.tap(find.text('Dołącz'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Czekamy na start gry...'), findsOneWidget);
    expect(find.text('Kuba'), findsOneWidget);
    expect(find.text('Prowadzący'), findsOneWidget);
    expect(find.text('Host'), findsOneWidget);
    expect(find.text('Gracze (2)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Gracze (3)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('pusty nick nie wpuszcza do lobby', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JoinedRoomScreen(roomId: 'ABC123', roomService: MockRoomService()),
      ),
    );

    await tester.tap(find.text('Dołącz'));
    await tester.pump();

    expect(find.text('Czekamy na start gry...'), findsNothing);
  });

  testWidgets('nieudane dołączenie pokazuje błąd i zostaje na formularzu',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JoinedRoomScreen(roomId: 'ABC123', roomService: FailingRoomService()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Kuba');
    await tester.tap(find.text('Dołącz'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Nie udało się dołączyć do pokoju.'), findsOneWidget);
    expect(find.text('Czekamy na start gry...'), findsNothing);
  });

  testWidgets('host widzi kod pokoju i graczy, a start otwiera planszę',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HostLobbyScreen(
          hostName: 'Ola',
          board: testBoard(),
          roomService: MockRoomService(joiners: const ['Ania']),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Pokój: '), findsOneWidget);
    expect(find.text('Ola'), findsOneWidget);
    expect(find.text('Gracze (1)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Gracze (2)'), findsOneWidget);

    await tester.tap(find.text('Zacznij grę'));
    await tester.pumpAndSettle();

    expect(find.byType(BingoBoardScreen), findsOneWidget);
    expect(find.text('Plansza testowa'), findsOneWidget);
  });

  testWidgets('host: błąd tworzenia pokoju daje przycisk ponowienia',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HostLobbyScreen(
          hostName: 'Ola',
          board: testBoard(),
          roomService: FailingRoomService(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Nie udało się utworzyć pokoju.'), findsOneWidget);
    expect(find.text('Spróbuj ponownie'), findsOneWidget);
  });
}
