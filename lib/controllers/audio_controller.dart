import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart';
import '../models/ambient_sound.dart';

class AudioController extends ChangeNotifier {
  final Map<String, FlutterSoundPlayer> _audioPlayers = {};
  final Set<String> _activeSounds = {};
  final Map<String, double> _soundVolumes = {};

  // Getters
  Set<String> get activeSounds => Set.from(_activeSounds);
  bool get isPlaying => _activeSounds.isNotEmpty;
  
  // Get volume for a specific sound
  double getSoundVolume(String soundId) {
    return _soundVolumes[soundId] ?? 0.5;
  }

  AudioController() {
    // Initialize is now handled per sound
  }

  // Get or create audio player for a sound
  Future<FlutterSoundPlayer> _getAudioPlayer(String soundId) async {
    if (!_audioPlayers.containsKey(soundId)) {
      final player = FlutterSoundPlayer();
      
      // Open the player first
      await player.openPlayer();
      
      final volume = getSoundVolume(soundId);
      await player.setVolume(volume);
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
      final player = await _getAudioPlayer(sound.id);
      
      // Stop any current playback
      await player.stopPlayer();
      
      // Load the asset data
      final ByteData data = await rootBundle.load(sound.assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Start playback with loop using fromDataBuffer
      await player.startPlayer(
        fromDataBuffer: bytes,
        whenFinished: () {
          // Restart the sound for looping
          if (_activeSounds.contains(sound.id)) {
            playSound(sound);
          }
        },
      );
      
      _activeSounds.add(sound.id);
      notifyListeners();
      
    } catch (e) {
      // debugPrint('Error playing sound ${sound.id}: $e');
      // Remove from active sounds if there was an error
      _activeSounds.remove(sound.id);
      notifyListeners();
    }
  }

  // Stop specific sound
  Future<void> stopSound(String soundId) async {
    final player = _audioPlayers[soundId];
    if (player != null) {
      try {
        await player.stopPlayer();
        _activeSounds.remove(soundId);
        notifyListeners();
        
      } catch (e) {
        // debugPrint('Error stopping sound $soundId: $e');
      }
    }
  }

  // Stop all sounds
  Future<void> stopAllSounds() async {
    for (final player in _audioPlayers.values) {
      try {
        await player.stopPlayer();
      } catch (e) {
        // debugPrint('Error stopping player: $e');
      }
    }
    _activeSounds.clear();
    notifyListeners();
  }

  // Set volume for a specific sound
  Future<void> setSoundVolume(String soundId, double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    _soundVolumes[soundId] = clampedVolume;
    
    final player = _audioPlayers[soundId];
    if (player != null) {
      try {
        await player.setVolume(clampedVolume);
      } catch (e) {
        // debugPrint('Error setting volume for $soundId: $e');
      }
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
      final alarmPlayer = FlutterSoundPlayer();
      await alarmPlayer.openPlayer();
      
      // Load the alarm asset data
      final ByteData data = await rootBundle.load('assets/sounds/alarm.mp3');
      final Uint8List bytes = data.buffer.asUint8List();
      
      await alarmPlayer.startPlayer(
        fromDataBuffer: bytes,
        whenFinished: () {
          alarmPlayer.closePlayer();
        },
      );
      
    } catch (e) {
      // debugPrint('Error playing alarm: $e');
    }
  }

  @override
  void dispose() {
    for (final player in _audioPlayers.values) {
      try {
        player.closePlayer();
      } catch (e) {
        // debugPrint('Error disposing player: $e');
      }
    }
    _audioPlayers.clear();
    super.dispose();
  }
} 