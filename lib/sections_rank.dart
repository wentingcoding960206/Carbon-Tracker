import 'package:flutter/material.dart';

class SectionsRank extends StatelessWidget {
  final int rank;
  final bool isUser;

  const SectionsRank({super.key, required this.rank, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isUser ? Colors.amber.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.orange : Colors.black,
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.person_outline),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUser ? 'You' : 'User $rank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text('5 g/km', style: TextStyle(fontSize: 16)),
              ],
            ),
          )

        ],
      ),
    );
  }
}
