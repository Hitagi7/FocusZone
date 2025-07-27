# FocusZone - Enhanced Pomodoro Timer (MVC Architecture)

A beautiful and feature-rich Flutter app that implements the Pomodoro Technique with ambient sounds, swipe navigation, motivational quotes, and modern UI design.

## Architecture: MVC (Model-View-Controller)

This project follows the **MVC (Model-View-Controller)** architecture for clear separation of concerns and maintainability:

- **Model**: Data structures, business logic, and state (e.g., timer, tasks, ambient sound models)
- **View**: UI components, widgets, and screens (e.g., timer display, quotes page, settings, etc.)
- **Controller**: Application logic, state management, and communication between model and view (e.g., timer controller, task controller, audio controller)

### Folder Structure

```
lib/
├── main.dart                  # App entry point, root widget
├── model/                     # Data models and business logic
│   ├── timer_config.dart
│   ├── timer_mode.dart
│   ├── task.dart
│   └── ambient_sound.dart
├── controller/                # Controllers (state management, app logic)
│   ├── timer_controller.dart
│   ├── task_controller.dart
│   ├── audio_controller.dart
│   └── notification_service.dart
├── view/                      # UI widgets, screens, and constants
│   ├── app_header.dart
│   ├── timer_display.dart
│   ├── quotes_page.dart
│   ├── task_list.dart
│   ├── task_add.dart
│   ├── sound_button.dart
│   ├── round_counter.dart
│   ├── control_buttons.dart
│   ├── user_settings.dart
│   ├── activity_report.dart
│   ├── timer_mode_selector.dart
│   ├── circular_progress_painter.dart
│   ├── ambient_sound_selector.dart
│   └── constants/
│       ├── app_constants.dart
│       └── theme_manager.dart
```

## Features

### Core Timer Features
- **Three Timer Modes**: Pomodoro (25min), Short Break (5min), Long Break (20min)
- **Customizable Durations**: User can modify timer lengths in settings
- **Auto-Start Options**: Automatically start breaks and pomodoros
- **Skip & Reset**: Skip to next timer or reset current timer
- **Round Counter**: Track completed pomodoro sessions

### Navigation & UI
- **Swipe Navigation**: Smooth page transitions between timer modes
- **Motivational Quotes**: Swipe left from Pomodoro to see inspirational quotes
- **Animated Backgrounds**: Dynamic GIF backgrounds for each timer mode
- **Haptic Feedback**: Tactile responses for better user experience
- **Modern Design**: Clean, minimalist interface with smooth animations

### Task Management
- **Task List**: Add and track tasks for each session
- **Task Persistence**: Tasks are saved and persist between sessions
- **Task Completion**: Mark tasks as completed during focus sessions

### Ambient Sound System
- **7 Ambient Sounds**: Rain, Fire, White Noise, Forest, Seashore, Cafe, Stream
- **Individual Volume Control**: Adjust volume for each sound independently
- **Sound Mixing**: Play multiple sounds simultaneously
- **Loop Playback**: Continuous ambient sound loops
- **Alarm Sound**: Notification sound when timer completes

### Notifications & Alerts
- **Local Notifications**: Timer completion alerts
- **Animated Notifications**: In-app animated completion messages
- **Mode-Specific Messages**: Different messages for pomodoro, short break, and long break completion

### Settings & Customization
- **Timer Duration Settings**: Customize pomodoro, short break, and long break durations
- **Auto-Start Preferences**: Configure automatic timer transitions
- **Notification Settings**: Control notification permissions and behavior
- **Theme Management**: Consistent color schemes and typography

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hitagi7/FocusZone.git
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
   or
   ```bash
   flutter run -d chrome
   ```

## Dependencies

### Core Dependencies
- `flutter_local_notifications`: Local notification system
- `shared_preferences`: Settings persistence
- `audioplayers`: Ambient sound playback
- `http`: API calls for motivational quotes
- `path_provider`: File system access
- `connectivity_plus`: Network connectivity checks

### Development Dependencies
- `flutter_lints`: Code quality and style enforcement

## For Developers

### Architecture Highlights
- **MVC Pattern**: Clean separation of data, UI, and logic
- **State Management**: Controllers use ChangeNotifier for reactive updates
- **Audio Integration**: Multi-track ambient sound playback with individual volume control
- **Custom Painting**: Circular progress indicators and custom UI elements
- **Asset Management**: Organized assets and constants

### Key Components
- **TimerController**: Manages timer state, auto-start logic, and mode transitions
- **AudioController**: Handles ambient sound playback, volume control, and alarm sounds
- **TaskController**: Manages task creation, persistence, and completion tracking
- **NotificationService**: Handles local notifications and permission requests

### Learning Resources
This app demonstrates:
- MVC architecture in Flutter
- State management with ChangeNotifier
- Audio playback and mixing
- Custom widget development
- Local notifications implementation
- Settings persistence
- API integration
- Clean, scalable project structure

## Asset Structure

```
assets/
├── images/
│   ├── pomodoro_bg.gif
│   ├── break_bg.gif
│   └── longbreak_bg.gif
└── sounds/
    ├── alarm.mp3
    ├── rain.mp3
    ├── fire.mp3
    ├── white_noise.mp3
    ├── forest.mp3
    ├── seashore.mp3
    ├── cafe.mp3
    └── stream.mp3
```

## Contributing

This project follows clean architecture principles and welcomes contributions. Please ensure:
- Code follows the existing MVC pattern
- New features include appropriate tests
- UI changes maintain the app's design consistency
- Audio features work across different devices and platforms
