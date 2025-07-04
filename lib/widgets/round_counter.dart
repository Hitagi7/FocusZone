import 'package:flutter/material.dart';
import '../models/timer_mode.dart';

class RoundCounter extends StatelessWidget {
  final int round;
  final TimerMode currentMode;

  const RoundCounter({
    Key? key,
    required this.round,
    required this.currentMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int completedPomodoros = round - 1;
    int currentCycle = ((completedPomodoros) ~/ 4) + 1;
    int pomodorosInCurrentCycle = completedPomodoros % 4;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              SizedBox(width: 8),
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
          SizedBox(height: 8),
          // Show progress dots for current cycle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              bool isCompleted = index < pomodorosInCurrentCycle;
              bool isCurrent = index == pomodorosInCurrentCycle && currentMode == TimerMode.pomodoro;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          SizedBox(height: 4),
          Text(
            'Cycle $currentCycle',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}