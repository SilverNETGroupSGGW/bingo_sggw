import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';

class BingoChecker {
  static bool checkBingo(List<BingoTile> tiles, int size) {
    for (int i = 0; i<size; i++){
      bool rowComplete = true;
      bool colComplete = true;

      for (int j = 0; j<size; j++){
        if (!tiles[i * size + j].isChecked) rowComplete = false;
        if (!tiles[j * size + i].isChecked) colComplete = false;
      }

      if (rowComplete || colComplete) return true;
    }

    bool mainDiagComplete = true;
    bool antiDiagComplete = true;

    for (int i = 0; i < size; i++) {
      if (!tiles[i * size + i].isChecked) mainDiagComplete = false;
      if (!tiles[(i + 1) * size - 1 - i].isChecked) antiDiagComplete = false;
    }

    return mainDiagComplete || antiDiagComplete;
  }
}