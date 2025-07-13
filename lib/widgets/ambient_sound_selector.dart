import 'package:flutter/material.dart';
import '../models/ambient_sound.dart';
import '../controllers/audio_controller.dart';

class AmbientSoundSelector extends StatefulWidget {
  final AudioController audioController;
  final VoidCallback? onSoundSelected;

  const AmbientSoundSelector({
    super.key,
    required this.audioController,
    this.onSoundSelected,
  });

  @override
  State<AmbientSoundSelector> createState() => _AmbientSoundSelectorState();
}

class _AmbientSoundSelectorState extends State<AmbientSoundSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Colors.grey[300],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ambient Sounds',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[100],
                    fontFamily: 'Noto Sans Display',
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          
          // Sound grid
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: AmbientSound.availableSounds.length,
              itemBuilder: (context, index) {
                final sound = AmbientSound.availableSounds[index];
                final isPlaying = widget.audioController.isSoundPlaying(sound.id);
                
                return _buildSoundCard(sound, isPlaying);
              },
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildSoundCard(AmbientSound sound, bool isPlaying) {
    return ListenableBuilder(
      listenable: widget.audioController,
      builder: (context, child) {
        final currentIsPlaying = widget.audioController.isSoundPlaying(sound.id);
        
        return GestureDetector(
          onTap: () {
            widget.audioController.toggleSound(sound);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: currentIsPlaying ? const Color(0xFF1E3A8A) : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentIsPlaying ? Colors.blue[400]! : Colors.grey[600]!,
                width: currentIsPlaying ? 2 : 1,
              ),
              boxShadow: currentIsPlaying
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sound.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  sound.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: currentIsPlaying ? Colors.blue[200] : Colors.grey[200],
                    fontFamily: 'Noto Sans Display',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),
                // Compact volume slider
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_down,
                        color: Colors.grey[400],
                        size: 12,
                      ),
                      Expanded(
                        child: Slider(
                          value: widget.audioController.getSoundVolume(sound.id),
                          onChanged: (value) {
                            widget.audioController.setSoundVolume(sound.id, value);
                          },
                          activeColor: currentIsPlaying ? Colors.blue[400] : Colors.grey[500],
                          inactiveColor: Colors.grey[700],
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: Colors.grey[400],
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 