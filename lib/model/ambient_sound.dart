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

  static const List<AmbientSound> availableSounds = [
    AmbientSound(
      id: 'rain',
      name: 'Rain',
      assetPath: 'sounds/rain.mp3',
      icon: '🌧️',
    ),
    AmbientSound(
      id: 'fire',
      name: 'Fire',
      assetPath: 'sounds/fire.mp3',
      icon: '🔥',
    ),
    AmbientSound(
      id: 'white_noise',
      name: 'White Noise',
      assetPath: 'sounds/white_noise.mp3',
      icon: '⚪',
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest',
      assetPath: 'sounds/forest.mp3',
      icon: '🌲',
    ),
    AmbientSound(
      id: 'seashore',
      name: 'Seashore',
      assetPath: 'sounds/seashore.mp3',
      icon: '🌊',
    ),
    AmbientSound(
      id: 'cafe',
      name: 'Cafe',
      assetPath: 'sounds/cafe.mp3',
      icon: '☕',
    ),
    AmbientSound(
      id: 'stream',
      name: 'Stream',
      assetPath: 'sounds/stream.mp3',
      icon: '💧',
    ),
  ];
} 