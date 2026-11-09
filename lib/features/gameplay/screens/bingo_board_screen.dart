import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
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
  late ConfettiController _confettiController;
  int _bingoCount = 0;
  Set<int> _bingoTileIndexes = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

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
      final lines = BingoChecker.findBingoLines(_tiles, widget.gridSize);

      if (lines.length > _bingoCount) {
        _confettiController.play();
      }

      _bingoCount = lines.length;
      _bingoTileIndexes = lines.expand((line) => line).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = _tiles.where((t) => t.isChecked).length;
    final totalCount = _tiles.length;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Bingo ${widget.gridSize}x${widget.gridSize}'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$checkedCount / $totalCount',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _bingoCount > 0 ? 1.0 : 0.0,
                      child: Chip(
                        label: Text(
                          _bingoCount > 1 ? '🎉 BINGO x$_bingoCount 🎉' : '🎉 BINGO! 🎉',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.amber,
                        avatar: const Icon(Icons.star, color: Colors.black, size: 18),
                        visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.gridSize,
                      crossAxisSpacing: 30/widget.gridSize,
                      mainAxisSpacing: 30/widget.gridSize,
                      ), 
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) {
                        final tile = _tiles[index];
                        return _BingoTileItem(
                          tile: tile,
                          isBingo: _bingoTileIndexes.contains(index),
                          onTap: () => _onTileTapped(index),
                        );
                      },
                    ),
                  )
                ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}


class _BingoTileItem extends StatelessWidget {
  final BingoTile tile;
  final bool isBingo;
  final VoidCallback onTap;

  const _BingoTileItem({
    required this.tile,
    required this.isBingo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = tile.isChecked
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: tile.isChecked
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: tile.isChecked
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: isBingo
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withAlpha(170),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.amber.withAlpha(70),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(6.0),
        child: Stack(
          children: [
            Center(
              child: Text(
                tile.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: foreground,
                ),
              ),
            ),
            if (tile.isChecked)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}