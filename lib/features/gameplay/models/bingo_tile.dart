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
}