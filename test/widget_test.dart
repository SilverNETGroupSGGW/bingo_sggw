import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bingo_sggw/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Menu główne prowadzi do pustej listy plansz',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BingoSGGW());
    await tester.pumpAndSettle();

    expect(find.text('Bingo SGGW'), findsWidgets);
    expect(find.text('Moje plansze'), findsOneWidget);
    expect(find.text('Nowa plansza'), findsOneWidget);
    expect(find.text('Kod pokoju'), findsOneWidget);
    expect(find.text('Zeskanuj kod QR'), findsOneWidget);

    await tester.tap(find.text('Moje plansze'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisane Plansze'), findsOneWidget);
    expect(find.text('Brak zapisanych plansz'), findsOneWidget);
  });

  testWidgets('Ręcznie wpisany kod pokoju otwiera ekran dołączania',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BingoSGGW());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(find.text('Dołączasz do pokoju ABC123'), findsOneWidget);
  });

  testWidgets('Zapis nowej planszy z menu otwiera Zapisane plansze',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BingoSGGW());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nowa plansza'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ZAPISZ'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisane Plansze'), findsOneWidget);
    expect(find.text('Moje Bingo 5x5'), findsOneWidget);
  });
}
