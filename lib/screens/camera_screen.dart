import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// ── App palette (matches the rest of ResiboScan) ─────────────────────────────
const _cerulean = Color(0xFF2D728F);
const _cream    = Color(0xFFFDF8EC);

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isHardwareError = false;
  bool _flashOn = false;
  Uint8List? _capturedBytes;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
      _isHardwareError = false;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera found on this device';
            _isInitializing = false;
          });
        }
        return;
      }

      // Prefer rear camera on mobile; first camera on web/desktop
      _currentCameraIndex = 0;
      if (!kIsWeb) {
        for (int i = 0; i < _cameras.length; i++) {
          if (_cameras[i].lensDirection == CameraLensDirection.back) {
            _currentCameraIndex = i;
            break;
          }
        }
      }

      await _startCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    // Dispose previous controller if any
    await _controller?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _flashOn = false;
          _capturedBytes = null;
        });
      }
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      _handleCameraError(e);
    }
  }

  void _handleCameraError(dynamic e) {
    if (!mounted) return;

    final msg = e.toString().toLowerCase();
    final isHardware = msg.contains('cameranotreadable') ||
        msg.contains('hardware') ||
        msg.contains('notreadable') ||
        msg.contains('in use') ||
        msg.contains('not available');

    setState(() {
      _isHardwareError = isHardware;
      _errorMessage = isHardware
          ? 'Camera unavailable'
          : 'Could not initialize camera';
      _isInitializing = false;
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _flashOn = !_flashOn;
      await _controller!.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() {});
    } catch (_) {
      // Flash not supported on this device
      _flashOn = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    setState(() => _isInitializing = true);
    await _startCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Turn off flash for the actual capture if torch was on
      if (_flashOn) {
        await _controller!.setFlashMode(FlashMode.auto);
      }
      final picture = await _controller!.takePicture();
      final Uint8List bytes = await picture.readAsBytes();
      if (mounted) {
        setState(() => _capturedBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Capture failed: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    }
  }

  void _retakePhoto() {
    setState(() => _capturedBytes = null);
    // Re-enable flash if it was on
    if (_flashOn && _controller != null && _controller!.value.isInitialized) {
      _controller!.setFlashMode(FlashMode.torch).catchError((_) {});
    }
  }

  void _confirmPhoto() {
    if (_capturedBytes != null) {
      Navigator.pop(context, _capturedBytes);
    }
  }

  @override
  void dispose() {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.dispose();
      }
    } catch (_) {}
    super.dispose();
  }

  // ── Error UI ───────────────────────────────────────────────────────────────
  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_photography_outlined,
              size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Camera unavailable',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_isHardwareError) ...[
              const SizedBox(height: 10),
              Text(
                'Your camera may be in use by another app.\nClose other apps and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cerulean,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text('Use Gallery Instead',
                  style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Viewfinder overlay ─────────────────────────────────────────────────────
  Widget _buildViewfinder() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.8,
            ),
          ),
          child: Stack(
            children: [
              // Corner accents (top-left)
              Positioned(top: -1, left: -1,
                child: _corner(true, true)),
              // Corner accents (top-right)
              Positioned(top: -1, right: -1,
                child: _corner(true, false)),
              // Corner accents (bottom-left)
              Positioned(bottom: -1, left: -1,
                child: _corner(false, true)),
              // Corner accents (bottom-right)
              Positioned(bottom: -1, right: -1,
                child: _corner(false, false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner(bool isTop, bool isLeft) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────
          if (_isInitializing)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  SizedBox(height: 16),
                  Text('Starting camera...',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            )
          else if (_errorMessage != null)
            _buildErrorUI()
          else if (_capturedBytes != null)
            // Captured image preview
            Positioned.fill(
              child: Image.memory(_capturedBytes!, fit: BoxFit.cover),
            )
          else
            // Live camera preview
            Positioned.fill(
              child: _controller != null && _controller!.value.isInitialized
                  ? ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.previewSize?.height ?? 1,
                          height: _controller!.value.previewSize?.width ?? 1,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

          // ── Viewfinder overlay (only during live preview) ───────
          if (!_isInitializing && _errorMessage == null && _capturedBytes == null)
            _buildViewfinder(),

          // ── Top bar ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    _circleButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    // Flash toggle (only during live preview)
                    if (!_isInitializing && _errorMessage == null && _capturedBytes == null)
                      _circleButton(
                        icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        onTap: _toggleFlash,
                        color: _flashOn ? Colors.amber : null,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom bar ──────────────────────────────────────────
          if (!_isInitializing && _errorMessage == null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flip camera
                      _capturedBytes == null
                          ? _circleButton(
                              icon: Icons.flip_camera_ios_outlined,
                              onTap: _cameras.length > 1 ? _flipCamera : null,
                              size: 44,
                              outlined: true,
                            )
                          : _circleButton(
                              icon: Icons.replay_rounded,
                              onTap: _retakePhoto,
                              size: 44,
                              outlined: true,
                            ),

                      // Capture button
                      GestureDetector(
                        onTap: _capturedBytes == null ? _capturePhoto : null,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                _capturedBytes == null ? 0.85 : 0.3),
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _capturedBytes == null
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Confirm button
                      AnimatedOpacity(
                        opacity: _capturedBytes != null ? 1.0 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: _circleButton(
                          icon: Icons.check_rounded,
                          onTap: _capturedBytes != null ? _confirmPhoto : null,
                          size: 44,
                          bgColor: _capturedBytes != null
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade800,
                          iconColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    VoidCallback? onTap,
    double size = 42,
    bool outlined = false,
    Color? color,
    Color? bgColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (bgColor ?? Colors.black.withOpacity(0.35)),
          shape: BoxShape.circle,
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Icon(icon,
          color: iconColor ?? color ?? Colors.white,
          size: size * 0.5),
      ),
    );
  }
}

// ── Corner accent painter ──────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, len);
      path.lineTo(0, 4);
      path.quadraticBezierTo(0, 0, 4, 0);
      path.lineTo(len, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width - len, 0);
      path.lineTo(size.width - 4, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 4);
      path.lineTo(size.width, len);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height - len);
      path.lineTo(0, size.height - 4);
      path.quadraticBezierTo(0, size.height, 4, size.height);
      path.lineTo(len, size.height);
    } else {
      path.moveTo(size.width - len, size.height);
      path.lineTo(size.width - 4, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 4);
      path.lineTo(size.width, size.height - len);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
