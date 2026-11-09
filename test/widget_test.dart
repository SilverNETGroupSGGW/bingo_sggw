import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bingo_sggw/main.dart';

void main() {
  testWidgets('Menu główne prowadzi do pustej listy plansz',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BingoSGGW());
    await tester.pumpAndSettle();

    expect(find.text('Bingo SGGW'), findsWidgets);
    expect(find.text('Moje plansze'), findsOneWidget);
    expect(find.text('Nowa plansza'), findsOneWidget);
    expect(find.text('Dołącz do pokoju'), findsOneWidget);

    await tester.tap(find.text('Moje plansze'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisane Plansze'), findsOneWidget);
    expect(find.text('Brak zapisanych plansz'), findsOneWidget);
  });
}
