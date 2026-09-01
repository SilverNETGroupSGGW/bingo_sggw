import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/widgets/bingo_tile_widget.dart';

class BingoBoardScreen extends StatelessWidget {
  final int gridSize;

  const BingoBoardScreen({
    super.key,
    this.gridSize = 3,
  });

  @override
  Widget build(BuildContext context) {
    final int totalTiles = gridSize * gridSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bingo SGGW $gridSize x $gridSize'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: totalTiles,
          itemBuilder: (context, index) {
            return BingoTileWidget(
              text: 'Hasło ${index + 1}',
            );
          },
        ),
      ),
    );
  }
}