import 'dart:convert';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';

class BingoBoard {
  final String id;
  final String title;
  final int size;
  final List<BingoTile> tiles;

  BingoBoard({
    required this.id,
    required this.title,
    required this.size,
    required this.tiles,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'size': size,
    'tiles': tiles.map((t) => t.toJson()).toList(),
  };

  factory BingoBoard.fromJson(Map<String, dynamic> json) => BingoBoard(
      id: json['id'] as String,
      title: json['title'] as String,
      size: json['size'] as int,
      tiles: (json['tiles'] as List).map((t) => BingoTile.fromJson(t as Map<String, dynamic>)).toList(),
    );

  String toRawJson() => jsonEncode(toJson());

  factory BingoBoard.fromRawJson(String str) =>
    BingoBoard.fromJson(jsonDecode(str) as Map<String, dynamic>);
}