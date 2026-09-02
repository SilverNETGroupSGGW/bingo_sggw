import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';

class BoardStorageService {
  static const String _keySavedBoards = 'saved_bingo_boards';

  static Future<void> saveBoard(BingoBoard board) async {
    final prefs = await SharedPreferences.getInstance();
    final List<BingoBoard> boards = await getSavedBoards();

    final index = boards.indexWhere((b) => b.id == board.id);
    if (index >= 0) {
      boards[index] = board;
    } else {
      boards.add(board);
    }

    final String encodedData = jsonEncode(boards.map((b) => b.toJson()).toList());
    await prefs.setString(_keySavedBoards, encodedData);
  }

  static Future<List<BingoBoard>> getSavedBoards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_keySavedBoards);

    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(rawData);
      return decodedList
          .map((item) => BingoBoard.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> deleteBoard(String boardId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<BingoBoard> boards = await getSavedBoards();

    boards.removeWhere((b) => b.id == boardId);

    final String encodedData = jsonEncode(boards.map((b) => b.toJson()).toList());
    await prefs.setString(_keySavedBoards, encodedData);
  }
}