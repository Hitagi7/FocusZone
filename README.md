# FocusZone - Enhanced Pomodoro Timer

A beautiful and feature-rich Flutter app that implements the Pomodoro Technique with ambient sounds, swipe navigation, and modern UI design.

## Features

### Core Timer Features

- **Three Timer Modes**: Pomodoro (25 min), Short Break (5 min), Long Break (15 min)
- **Swipe Navigation**: Smooth swipe left/right to switch between timer modes
- **Circular Progress**: Visual progress indicator with smooth animations
- **Smart Controls**: Start/pause, reset, and skip buttons with haptic feedback
- **Round Counter**: Tracks completed Pomodoro sessions
- **Auto Mode Switching**: Automatically transitions between work and break sessions

### Audio Features

- **Ambient Sounds**: 7 different ambient sounds (Rain, Fire, White Noise, Forest, Seashore, Cafe, Stream)
- **Volume Control**: Individual volume sliders for each ambient sound
- **Sound Mixing**: Play multiple ambient sounds simultaneously
- **Audio Persistence**: Sounds continue playing when switching timer modes
- **Alarm Sounds**: Notification sounds when timer sessions complete

### Enhanced UI/UX

- **Modern Design**: Clean, minimalist interface with smooth animations
- **Dynamic Backgrounds**: Animated background for Pomodoro mode
- **Haptic Feedback**: Tactile feedback for better user experience
- **Completion Notifications**: Animated toast notifications when sessions complete
- **Responsive Layout**: Optimized for different screen sizes
- **Dark Theme**: Beautiful dark color scheme with proper contrast

## Project Structure

```
lib/
├── main.dart                    # Main app entry point
├── constants/
│   └── app_constants.dart       # App-wide constants (colors, times, sizes)
├── models/
│   ├── timer_mode.dart          # Timer mode enum (pomodoro, shortBreak, longBreak)
│   ├── timer_config.dart        # Configuration for each timer mode
│   └── ambient_sound.dart       # Ambient sound model and available sounds
├── controllers/
│   ├── timer_controller.dart    # Manages timer state and logic
│   └── audio_controller.dart    # Manages ambient sounds and audio playback
└── widgets/
    ├── app_header.dart          # App header with title and navigation
    ├── timer_display.dart       # Timer display with circular progress
    ├── circular_progress_painter.dart # Custom painter for progress circle
    ├── control_buttons.dart     # Reset and skip buttons
    ├── round_counter.dart       # Displays current round number
    ├── sound_button.dart        # Floating action button for audio controls
    ├── ambient_sound_selector.dart # Modal bottom sheet for sound selection
    └── timer_mode_selector.dart # Timer mode selection widget
```

## Dependencies

- **audioplayers**: ^5.2.1 - For ambient sound playback
- **path_provider**: ^2.1.1 - For file system access
- **flutter_lints**: ^5.0.0 - For code quality

## How It Works

### Timer System

1. **Timer Modes**: Three different timer modes with different durations and colors
2. **Swipe Navigation**: PageView allows smooth swiping between timer modes
3. **State Management**: TimerController manages timer state using ChangeNotifier
4. **Auto Transitions**: Automatically switches to next mode when timer completes

### Audio System

1. **Ambient Sounds**: Multiple audio players for different ambient sounds
2. **Volume Control**: Individual volume sliders for each sound
3. **Sound Mixing**: Can play multiple sounds simultaneously
4. **Audio Persistence**: Sounds continue across timer mode changes

### UI Components

1. **Custom Painters**: Smooth circular progress indicators
2. **Animations**: Fade and slide animations for better UX
3. **Responsive Design**: Adapts to different screen sizes
4. **Haptic Feedback**: Tactile feedback for interactions

## Key Components

- **TimerController**: Manages timer state, handles start/pause/reset logic, auto mode switching
- **AudioController**: Manages ambient sounds, volume control, and audio playback
- **TimerDisplay**: Shows the timer with animated circular progress indicator
- **AmbientSoundSelector**: Modal bottom sheet for selecting and controlling ambient sounds
- **PageView**: Enables smooth swipe navigation between timer modes

## Getting Started

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd FocusZone
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## For Developers

This app demonstrates:

- **State Management**: ChangeNotifier pattern for reactive UI
- **Custom Painting**: CustomPainter for circular progress indicators
- **Audio Integration**: Multi-track audio playback with volume control
- **PageView Navigation**: Smooth swipe navigation between screens
- **Modal Bottom Sheets**: Custom modal dialogs with animations
- **Haptic Feedback**: Tactile feedback for better UX
- **Asset Management**: Proper asset organization and loading
- **Clean Architecture**: Separated concerns with controllers, models, and widgets

## Features for Beginners

This app is an excellent learning resource for:

- Basic Flutter widgets (Container, Text, Icon, etc.)
- State management with ChangeNotifier
- Custom painting with CustomPainter
- PageView for swipe navigation
- Audio integration with audioplayers
- Modal bottom sheets and overlays
- Haptic feedback integration
- Asset management and loading
- Clean project structure with separate folders for different concerns
