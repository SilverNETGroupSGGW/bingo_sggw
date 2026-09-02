import 'package:flutter/material.dart';
import 'package:bingo_sggw/features/board_creation/models/bingo_board.dart';
import 'package:bingo_sggw/core/services/board_storage_service.dart';
import 'package:bingo_sggw/features/gameplay/screens/bingo_board_screen.dart';
import 'package:bingo_sggw/features/board_creation/screens/board_creation_screen.dart';

class SavedBoardsScreen extends StatefulWidget {
  const SavedBoardsScreen({super.key});

  @override
  State<SavedBoardsScreen> createState() => _SavedBoardsScreenState();
}

class _SavedBoardsScreenState extends State<SavedBoardsScreen> {
  late Future<List<BingoBoard>> _boardsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBoards();
  }

  void _refreshBoards() {
    setState(() {
      _boardsFuture = BoardStorageService.getSavedBoards();
    });
  }

  void _openBoardEditor([BingoBoard? board]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BoardCreationScreen(existingBoard: board),
      ),
    );

    if (result == true || result == null) {
      _refreshBoards();
    }
  }

  Future<void> _deleteBoard(String boardId, String boardTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń planszę'),
        content: Text('Czy na pewno chcesz usunąć planszę "$boardTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BoardStorageService.deleteBoard(boardId);
      _refreshBoards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zapisane Plansze'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBoardEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Nowa plansza'),
        ),
      body: FutureBuilder<List<BingoBoard>>(
        future: _boardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final boards = snapshot.data ?? [];

          if (boards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Brak zapisanych plansz',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Stwórz nową planszę w formularzu głównym!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${board.size}x${board.size}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    board.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Liczba kafelków: ${board.tiles.length}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Usuń planszę',
                        onPressed: () => _deleteBoard(board.id, board.title),
                      ),
                    ],
                  ),
                  onTap: () => _openBoardEditor(board),
                ),
              );
            },
          );
        },
      ),
    );
  }
}