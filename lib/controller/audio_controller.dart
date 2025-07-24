import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../model/ambient_sound.dart';

class AudioController extends ChangeNotifier {
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Set<String> _activeSounds = {};
  final Map<String, double> _soundVolumes = {};

  // Getters
  Set<String> get activeSounds => Set.from(_activeSounds);
  bool get isPlaying => _activeSounds.isNotEmpty;

  // Get volume for a specific sound
  double getSoundVolume(String soundId) {
    return _soundVolumes[soundId] ?? 0.5;
  }

  AudioController();

  // Get or create audio player for a sound
  AudioPlayer _getAudioPlayer(String soundId) {
    if (!_audioPlayers.containsKey(soundId)) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.loop);
      final volume = getSoundVolume(soundId);
      player.setVolume(volume);
      _audioPlayers[soundId] = player;
    }
    return _audioPlayers[soundId]!;
  }

  // Toggle sound on/off
  Future<void> toggleSound(AmbientSound sound) async {
    if (_activeSounds.contains(sound.id)) {
      await stopSound(sound.id);
    } else {
      await playSound(sound);
    }
  }

  // Play ambient sound
  Future<void> playSound(AmbientSound sound) async {
    try {
      final player = _getAudioPlayer(sound.id);
      await player.play(AssetSource(sound.assetPath));
      _activeSounds.add(sound.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing sound ${sound.id}: $e');
    }
  }

  // Stop specific sound
  Future<void> stopSound(String soundId) async {
    final player = _audioPlayers[soundId];
    if (player != null) {
      await player.stop();
      _activeSounds.remove(soundId);
      notifyListeners();
    }
  }

  // Stop all sounds
  Future<void> stopAllSounds() async {
    for (final player in _audioPlayers.values) {
      await player.stop();
    }
    _activeSounds.clear();
    notifyListeners();
  }

  // Set volume for a specific sound
  void setSoundVolume(String soundId, double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    _soundVolumes[soundId] = clampedVolume;
    final player = _audioPlayers[soundId];
    if (player != null) {
      player.setVolume(clampedVolume);
    }
    notifyListeners();
  }

  // Check if a specific sound is playing
  bool isSoundPlaying(String soundId) {
    return _activeSounds.contains(soundId);
  }

  // Play alarm sound (for timer completion)
  Future<void> playAlarm() async {
    try {
      final alarmPlayer = AudioPlayer();
      await alarmPlayer.play(AssetSource('sounds/alarm.mp3'));
      // Don't add to active sounds since it's a one-time alarm
    } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  @override
  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    super.dispose();
  }
}
