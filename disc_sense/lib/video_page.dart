import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'bluetooth.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool _isRecording = false;
  bool _isInitializing = true;
  String? _errorMessage;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera({int cameraIndex = 0}) async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    await _controller?.dispose();
    _controller = null;

    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        throw CameraException(
          'unsupportedPlatform',
          'Camera preview is not supported on this desktop platform.',
        );
      }

      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        throw CameraException('noCamera', 'No cameras are available.');
      }

      final safeIndex = cameraIndex.clamp(0, _cameras.length - 1).toInt();
      _cameraIndex = safeIndex;
      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      // The minimum zoom level is the widest field of view available.
      final minZoom = await controller.getMinZoomLevel();
      await controller.setZoomLevel(minZoom);

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Could not start the camera: $error';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    await _initializeCamera(cameraIndex: (_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _toggleRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (_isRecording) {
        await controller.stopVideoRecording();
        if(BluetoothPeripheral.isConnected()) {
          BluetoothPeripheral.sendData("stop");
        }
      } else {
        await controller.startVideoRecording();
        if(BluetoothPeripheral.isConnected()) {
          BluetoothPeripheral.sendData("start");
        }
      }
      if (!mounted) return;
      setState(() => _isRecording = !_isRecording);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not change recording: $error';
      });
    }
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const ColoredBox(
        color: Color(0xFF18201E),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return ColoredBox(
        color: const Color(0xFF18201E),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage ?? 'Camera unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return CameraPreview(controller);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record video'),
        actions: [
          IconButton(
            onPressed: _cameras.length > 1 && !_isInitializing
                ? _switchCamera
                : null,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox.expand(child: _buildCameraPreview()),
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  _controller?.value.isInitialized == true && !_isInitializing
                  ? _toggleRecording
                  : null,
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
