import 'package:flutter/material.dart';

class BingoTile {
  final String id;
  final String text;
  bool isChecked;

  BingoTile({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isChecked': isChecked,
  };

  factory BingoTile.fromJson(Map<String, dynamic> json) => BingoTile(
      id: json['id'] as String,
      text: json['text'] as String,
      isChecked: json['isChecked'] as bool ?? false,
    );
}