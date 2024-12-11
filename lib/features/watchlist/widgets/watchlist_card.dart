import 'package:flutter/material.dart';

class WatchlistCard extends StatelessWidget {
  final String symbol;
  final String price;
  final String volume;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const WatchlistCard({
    Key? key,
    required this.symbol,
    required this.price,
    required this.volume,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          symbol,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: $price'),
            Text('Volume: $volume'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap, // Handle card tap
      ),
    );
  }
}
