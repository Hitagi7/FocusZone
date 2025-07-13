import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../models/timer_config.dart';

class TimerModeSelector extends StatelessWidget {
  final TimerMode currentMode;
  final Function(TimerMode) onModeChanged;

  const TimerModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TimerMode.values.map((mode) {
        bool isSelected = currentMode == mode;
        final config = TimerConfigManager.getConfig(mode);

        return Expanded(
          child: GestureDetector(
            onTap: () => onModeChanged(mode),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  config.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}