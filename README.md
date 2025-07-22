# FocusZone - Enhanced Pomodoro Timer (MVC Architecture)

A beautiful and feature-rich Flutter app that implements the Pomodoro Technique with ambient sounds, swipe navigation, motivational quotes, and modern UI design.

## Architecture: MVC (Model-View-Controller)

This project follows the **MVC (Model-View-Controller)** architecture for clear separation of concerns and maintainability:

- **Model**: Data structures, business logic, and state (e.g., timer, tasks, ambient sound models)
- **View**: UI components, widgets, and screens (e.g., timer display, quotes page, settings, etc.)
- **Controller**: Application logic, state management, and communication between model and view (e.g., timer controller, task controller)

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

- **Three Timer Modes**: Pomodoro, Short Break, Long Break
- **Motivational Quotes**: Swipe left from Pomodoro to see a new quote, with refresh button
- **Task Management**: Add and track tasks for each session
- **Ambient Sounds**: Play and mix relaxing background sounds
- **Customizable Settings**: User preferences for timer durations, auto-start, and more
- **Notifications**: Local notifications for session completion
- **Reports**: Activity and productivity reports
- **Modern UI/UX**: Responsive, animated, and beautiful design

## How It Works (MVC)

- **Model**: Defines timer/task/quote data, manages persistence and business rules
- **View**: Renders UI, listens to controller for updates, and displays data
- **Controller**: Handles user input, updates model, and notifies view of changes

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

- **MVC Pattern**: Clean separation of data, UI, and logic
- **State Management**: Controllers use ChangeNotifier for reactive updates
- **API Integration**: Motivational quotes fetched from ZenQuotes API
- **Custom Painting**: Circular progress indicators
- **Audio Integration**: Multi-track ambient sound playback
- **Asset Management**: Organized assets and constants

## Learning Resource

This app is an excellent example for learning:

- MVC architecture in Flutter
- State management with controllers
- API integration and async programming
- Custom widgets and UI composition
- Clean, scalable project structure
