import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bingo_sggw/main.dart';

void main() {
  testWidgets('Pusty ekran startowy pokazuje brak zapisanych plansz',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BingoSGGW());
    await tester.pumpAndSettle();

    expect(find.text('Zapisane Plansze'), findsOneWidget);
    expect(find.text('Brak zapisanych plansz'), findsOneWidget);
  });
}
