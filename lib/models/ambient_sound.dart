class AmbientSound {
  final String id;
  final String name;
  final String assetPath;
  final String icon;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.icon,
  });

  // Predefined ambient sounds
  static const List<AmbientSound> availableSounds = [
    AmbientSound(
      id: 'rain',
      name: 'Rain',
      assetPath: 'assets/sounds/rain.mp3',
      icon: '🌧️',
    ),
    AmbientSound(
      id: 'fire',
      name: 'Fire',
      assetPath: 'assets/sounds/fire.mp3',
      icon: '🔥',
    ),
    AmbientSound(
      id: 'white_noise',
      name: 'White Noise',
      assetPath: 'assets/sounds/white_noise.mp3',
      icon: '⚪',
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest',
      assetPath: 'assets/sounds/forest.mp3',
      icon: '🌲',
    ),
    AmbientSound(
      id: 'seashore',
      name: 'Seashore',
      assetPath: 'assets/sounds/seashore.mp3',
      icon: '🌊',
    ),
    AmbientSound(
      id: 'cafe',
      name: 'Cafe',
      assetPath: 'assets/sounds/cafe.mp3',
      icon: '☕',
    ),
    AmbientSound(
      id: 'stream',
      name: 'Stream',
      assetPath: 'assets/sounds/stream.mp3',
      icon: '💧',
    ),
  ];
} 