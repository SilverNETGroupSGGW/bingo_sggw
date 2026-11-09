import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';

class BingoChecker {
  static List<List<int>> findBingoLines(List<BingoTile> tiles, int size) {
    final lines = <List<int>>[];

    void addIfComplete(List<int> indexes) {
      if (indexes.every((i) => tiles[i].isChecked)) lines.add(indexes);
    }

    for (int i = 0; i < size; i++) {
      addIfComplete([for (int j = 0; j < size; j++) i * size + j]);
      addIfComplete([for (int j = 0; j < size; j++) j * size + i]);
    }

    addIfComplete([for (int i = 0; i < size; i++) i * size + i]);
    addIfComplete([for (int i = 0; i < size; i++) (i + 1) * size - 1 - i]);

    return lines;
  }
}
