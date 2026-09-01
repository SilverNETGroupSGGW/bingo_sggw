import 'package:flutter/material.dart';

class BingoTileWidget extends StatefulWidget {
  final String text;

  const BingoTileWidget({super.key, required this.text});

  @override
  State<BingoTileWidget> createState() => _BingoTileWidgetState();
}

class _BingoTileWidgetState extends State<BingoTileWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isChecked ? Colors.green : Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isChecked ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}