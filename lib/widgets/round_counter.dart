import 'package:flutter/material.dart';

// Displays the current round and cycle information
class RoundCounter extends StatelessWidget {
  final int round;

  const RoundCounter({
    super.key,
    required this.round,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon
          Icon(
            Icons.timer,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          
          // Round number
          Text(
            'Round #$round',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}