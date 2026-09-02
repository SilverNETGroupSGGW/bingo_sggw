import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/gameplay/models/bingo_tile.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/core/services/board_storage_service.dart';

class BoardCreationScreen extends StatefulWidget {
  final BingoBoard? existingBoard;
  
  const BoardCreationScreen({super.key, this.existingBoard});

  @override
  State<BoardCreationScreen> createState() => _BoardCreationScreenState();
}

class _BoardCreationScreenState extends State<BoardCreationScreen> {
  int _gridSize = 5;
  late List<TextEditingController> _controllers;
  final TextEditingController _titleController = TextEditingController();
  String? _boardId;

  @override
  void initState() {
    super.initState();

    if (widget.existingBoard != null){
      _boardId = widget.existingBoard!.id;
      _titleController.text = widget.existingBoard!.title;
      _gridSize = widget.existingBoard!.size;
      _controllers = widget.existingBoard!.tiles.map((tile) => TextEditingController(text: tile.text)).toList();
    }
    else{
      _initControllers();
    }
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
    _titleController.dispose();
    super.dispose();
  }

  void _updateGridSize(int newSize) {
    setState(() {
      _gridSize = newSize;
      _initControllers();
    });
  }

  BingoBoard _buildBoardObject(){
    final title = _titleController.text.trim().isEmpty ? 'Moje Bingo ${_gridSize}x${_gridSize}' : _titleController.text.trim();

    final customTiles = _controllers.asMap().entries.map((entry) {
      return BingoTile(
        id: entry.key.toString(),
        text: entry.value.text.trim().isEmpty ? 'Hasło ${entry.key+1}' : entry.value.text.trim()
      );
    }).toList();

    return BingoBoard(
      id: _boardId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      size: _gridSize,
      tiles: customTiles
    );
  }

  Future<void> _saveBoard() async {
    final board = _buildBoardObject();
    await BoardStorageService.saveBoard(board);
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plansza została zapisana!')),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _saveAndPlay() async {
    final board = _buildBoardObject();
    await BoardStorageService.saveBoard(board);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BingoBoardScreen(
            gridSize: board.size,
            initialTiles: board.tiles,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBoard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edycja planszy' : 'Stwórz własne Bingo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł planszy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rozmiar siatki:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Slider(
                    value: _gridSize.toDouble(),
                    min: 3.0,
                    max: 6.0,
                    divisions: 3,
                    label: '${_gridSize}x$_gridSize',
                    onChanged: (double newValue) {
                      _updateGridSize(newValue.toInt());
                    },
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
                        labelText: 'Pole ${index+1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveBoard,
                    icon: const Icon(Icons.save),
                    label: const Text('ZAPISZ'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveAndPlay,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('GRAJ'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}