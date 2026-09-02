import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/widgets/bingo_tile_widget.dart';
import 'package:bingo_sggw/core/utils/bingo_checker.dart';

class BingoBoardScreen extends StatefulWidget {
  final int gridSize;
  final List<BingoTile>? initialTiles;

  const BingoBoardScreen({
    super.key,
    this.gridSize = 5,
    this.initialTiles,
  });

  @override createState() => _BingoBoardScreenState();
}

class _BingoBoardScreenState extends State<BingoBoardScreen> {
  late List<BingoTile> _tiles;
  bool _hasWon = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTiles != null){
      _tiles = widget.initialTiles!;
    }
    else{
      final int total = widget.gridSize * widget.gridSize;
      _tiles = List.generate(
        total,
        (index) => BingoTile(id: index.toString(), text: 'Haslo ${index+1}',
        ),
      );
    }
  }

  void _onTileTapped(int index){
    setState(() {
      _tiles[index].isChecked = !_tiles[index].isChecked;
      _hasWon = BingoChecker.checkBingo(_tiles, widget.gridSize);
    });

    if (_hasWon) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('!BINGO!'),
        content: const Text('Gratulacje!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Graj dalej'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bingo ${widget.gridSize} x ${widget.gridSize}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: _tiles.length,
          itemBuilder: (context, index) {
            final tile = _tiles[index];
            return GestureDetector(
              onTap: () => _onTileTapped(index),
              child: Container(
                decoration: BoxDecoration(
                  color: tile.isChecked ? Colors.green : Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tile.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tile.isChecked ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}