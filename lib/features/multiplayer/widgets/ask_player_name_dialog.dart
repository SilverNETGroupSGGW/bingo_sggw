import 'package:flutter/material.dart';

Future<String?> askPlayerName(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _PlayerNameDialog(),
  );
}

class _PlayerNameDialog extends StatefulWidget {
  const _PlayerNameDialog();

  @override
  State<_PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<_PlayerNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jak się nazywasz?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'Nick',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Dalej'),
        ),
      ],
    );
  }
}
