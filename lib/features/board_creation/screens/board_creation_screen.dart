import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/multiplayer/screens/scan_qr_screen.dart';

class BoardCreationScreen extends StatefulWidget {
  const BoardCreationScreen({super.key});

  @override
  State<BoardCreationScreen> createState() => _BoardCreationScreenState();
}

class _BoardCreationScreenState extends State<BoardCreationScreen> {
  int _gridSize = 3;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final totalTiles = _gridSize * _gridSize;
    _controllers = List.generate(
      totalTiles,
      (index) => TextEditingController(text: 'Hasło ${index + 1}'),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateGridSize(int newSize) {
    setState(() {
      _gridSize = newSize;
      _initControllers();
    });
  }

  void _startGame() {
    final customTiles = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return BingoTile(
        id: index.toString(),
        text: controller.text.trim().isEmpty ? 'Hasło ${index + 1}' : controller.text.trim(),
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BingoBoardScreen(
          gridSize: _gridSize,
          initialTiles: customTiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stwórz własne Bingo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Zeskanuj kod pokoju',
            onPressed: () async {
              // Otwieramy nasz skaner QR
              final roomId = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (context) => const ScanQrScreen()),
              );

              if (roomId != null && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text('Pokój: $roomId')),
                      body: Center(
                        child: Text('Dołączono do pokoju: $roomId'),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Rozmiar: ${_gridSize}x$_gridSize',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: _gridSize.toDouble(),
                    min: 3.0,
                    max: 6.0,
                    divisions: 3,
                    label: '${_gridSize}x$_gridSize',
                    onChanged: (double newValue) {
                      _updateGridSize(newValue.toInt());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        labelText: 'Pole ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('START GAME', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}