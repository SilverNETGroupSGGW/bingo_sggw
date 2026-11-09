import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_sggw/features/multiplayer/screens/joined_room_screen.dart';

void main() {
  testWidgets('gość wpisuje nick i widzi lobby z listą graczy',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: JoinedRoomScreen(roomId: 'ABC123')),
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
      const MaterialApp(home: JoinedRoomScreen(roomId: 'ABC123')),
    );

    await tester.tap(find.text('Dołącz'));
    await tester.pump();

    expect(find.text('Czekamy na start gry...'), findsNothing);
  });
}
