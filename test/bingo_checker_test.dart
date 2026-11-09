import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_sggw/core/utils/bingo_checker.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';

List<BingoTile> boardWithChecked(int size, Set<int> checked) => [
      for (int i = 0; i < size * size; i++)
        BingoTile(id: '$i', text: '$i', isChecked: checked.contains(i)),
    ];

void main() {
  test('pusta plansza nie ma bingo', () {
    expect(BingoChecker.findBingoLines(boardWithChecked(3, {}), 3), isEmpty);
  });

  test('jeden rząd to jedno bingo', () {
    final lines = BingoChecker.findBingoLines(boardWithChecked(3, {0, 1, 2}), 3);
    expect(lines, [
      [0, 1, 2]
    ]);
  });

  test('rząd i kolumna przecinające się liczą się jako x2', () {
    final lines =
        BingoChecker.findBingoLines(boardWithChecked(3, {0, 1, 2, 3, 6}), 3);
    expect(lines.length, 2);
  });

  test('obie przekątne dają x2', () {
    final lines =
        BingoChecker.findBingoLines(boardWithChecked(3, {0, 2, 4, 6, 8}), 3);
    expect(lines.length, 2);
  });

  test('pełna plansza 3x3 to 8 linii', () {
    final all = {for (int i = 0; i < 9; i++) i};
    expect(BingoChecker.findBingoLines(boardWithChecked(3, all), 3).length, 8);
  });
}
