import 'package:flutter/material.dart';

class WatchlistCard extends StatelessWidget {
  final String symbol;
  final VoidCallback onRemove;

  const WatchlistCard({
    Key? key,
    required this.symbol,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(symbol),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
