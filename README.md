# FocusZone - Simple Pomodoro Timer

A simple Flutter app that implements the Pomodoro Technique with swipe navigation.

## Features

- **Three Timer Modes**: Pomodoro (25 min), Short Break (5 min), Long Break (15 min)
- **Swipe Navigation**: Swipe left/right to switch between timer modes
- **Circular Progress**: Visual progress indicator around the timer
- **Simple Controls**: Start/pause, reset, and skip buttons
- **Round Counter**: Tracks completed Pomodoro sessions

## Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── constants/
│   └── app_constants.dart    # App-wide constants (colors, times, sizes)
├── models/
│   ├── timer_mode.dart       # Timer mode enum (pomodoro, shortBreak, longBreak)
│   └── timer_config.dart     # Configuration for each timer mode
├── controllers/
│   └── timer_controller.dart # Manages timer state and logic
└── widgets/
    ├── app_header.dart       # Simple app header with title
    ├── timer_display.dart    # Timer display with circular progress
    ├── circular_progress_painter.dart # Custom painter for progress circle
    ├── control_buttons.dart  # Reset and skip buttons
    └── round_counter.dart    # Displays current round number
```

## How It Works

1. **Timer Modes**: Three different timer modes with different durations and colors
2. **Swipe Navigation**: PageView allows swiping between timer modes
3. **State Management**: TimerController manages timer state using ChangeNotifier
4. **UI Components**: Simple, reusable widgets for each part of the interface

## Key Components

- **TimerController**: Manages timer state, handles start/pause/reset logic
- **TimerDisplay**: Shows the timer with circular progress indicator
- **PageView**: Enables swipe navigation between timer modes
- **Custom Painter**: Draws the circular progress indicator

## For Beginners

This app demonstrates:
- Basic Flutter widgets (Container, Text, Icon, etc.)
- State management with ChangeNotifier
- Custom painting with CustomPainter
- PageView for swipe navigation
- Simple timer logic with Timer.periodic
- Clean project structure with separate folders for different concerns
