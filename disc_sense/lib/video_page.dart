import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record video'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.flip_camera_ios_outlined),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF18201E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red
                              : Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            _isRecording ? 'REC  00:00' : 'READY',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording
                  ? 'Recording the action...'
                  : 'Position the camera to capture the field.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() => _isRecording = !_isRecording),
              style: FilledButton.styleFrom(
                backgroundColor: _isRecording
                    ? colorScheme.error
                    : colorScheme.primary,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(_isRecording ? 'Stop recording' : 'Start recording'),
            ),
          ],
        ),
      ),
    );
  }
}
