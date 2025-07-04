enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
}

extension TimerModeExtension on TimerMode {
  String get displayName {
    switch (this) {
      case TimerMode.pomodoro:
        return 'Pomodoro';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }
}