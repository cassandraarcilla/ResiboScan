import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

const _cerulean = Color(0xFF2D728F);
const _cream    = Color(0xFFFDF8EC);

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(cameraController.description);
    }
  }

  Future<void> _disposeController() async {
    if (_controller == null) return;
    await _controller!.dispose();
    _controller = null;
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
        _setErrorMessage('No camera found on this device');
        return;
      }

      _currentCameraIndex = 0;
      if (!kIsWeb) {
        final backIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
        if (backIdx != -1) _currentCameraIndex = backIdx;
      }

      await _startCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      _handleCameraError(e);
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    await _disposeController();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _flashOn = false;
          _capturedBytes = null;
        });
      }
    } catch (e) {
      _handleCameraError(e);
    }
  }

  void _setErrorMessage(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _isInitializing = false;
    });
  }

  void _handleCameraError(dynamic e) {
    if (!mounted) return;
    final msg = e.toString().toLowerCase();
    final isHardware = msg.contains('cameranotreadable') || 
                       msg.contains('hardware') || 
                       msg.contains('in use');

    setState(() {
      _isHardwareError = isHardware;
      _errorMessage = isHardware ? 'Camera unavailable' : 'Could not initialize camera';
      _isInitializing = false;
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _flashOn = !_flashOn;
      await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (_) {
      setState(() => _flashOn = false);
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
      if (_flashOn) await _controller!.setFlashMode(FlashMode.auto);
      
      final picture = await _controller!.takePicture();
      final bytes = await picture.readAsBytes();
      
      if (mounted) setState(() => _capturedBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e'), backgroundColor: Colors.red.shade700)
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() => _capturedBytes = null);
    if (_flashOn) _controller?.setFlashMode(FlashMode.torch).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildPrimaryContent(),
          if (!_isInitializing && _errorMessage == null && _capturedBytes == null) _buildViewfinder(),
          _buildTopOverlay(),
          if (!_isInitializing && _errorMessage == null) _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildPrimaryContent() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 16),
            Text('Starting camera...', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }
    if (_errorMessage != null) return _buildErrorUI();
    if (_capturedBytes != null) return Positioned.fill(child: Image.memory(_capturedBytes!, fit: BoxFit.cover));

    return Positioned.fill(
      child: _controller != null && _controller!.value.isInitialized
          ? Center(
              child: CameraPreview(_controller!),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
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
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(40)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleButton(
                icon: _capturedBytes == null ? Icons.flip_camera_ios_outlined : Icons.replay_rounded,
                onTap: _capturedBytes == null ? (_cameras.length > 1 ? () => _flipCamera() : null) : _retakePhoto,
                size: 44,
                outlined: true,
              ),
              GestureDetector(
                onTap: _capturedBytes == null ? _capturePhoto : null,
                child: _buildCaptureButtonInner(),
              ),
              AnimatedOpacity(
                opacity: _capturedBytes != null ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: _circleButton(
                  icon: Icons.check_rounded,
                  onTap: _capturedBytes != null ? () => Navigator.pop(context, _capturedBytes) : null,
                  size: 44,
                  bgColor: _capturedBytes != null ? const Color(0xFF4CAF50) : Colors.grey.shade800,
                  iconColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButtonInner() {
    final bool isIdle = _capturedBytes == null;
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(isIdle ? 0.85 : 0.3), width: 4),
      ),
      child: Center(
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: isIdle ? Colors.white : Colors.white.withOpacity(0.3), shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_photography_outlined, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 20),
            Text(_errorMessage ?? 'Camera unavailable', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            if (_isHardwareError) ...[
              const SizedBox(height: 10),
              const Text('Your camera may be in use by another app.\nClose other apps and try again.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5)),
            ],
            const SizedBox(height: 32),
            _actionButton(onPressed: _initCamera, icon: Icons.refresh_rounded, label: 'Try Again', isPrimary: true),
            const SizedBox(height: 12),
            _actionButton(onPressed: () => Navigator.pop(context), icon: Icons.image_outlined, label: 'Use Gallery Instead', isPrimary: false),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required VoidCallback onPressed, required IconData icon, required String label, required bool isPrimary}) {
    return SizedBox(
      width: 200, height: 46,
      child: isPrimary 
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: _cerulean, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.grey.shade600), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
    );
  }

  Widget _buildViewfinder() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280, height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _ViewfinderCornerPainter())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap, double size = 42, bool outlined = false, Color? color, Color? bgColor, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (bgColor ?? Colors.black.withOpacity(0.35)),
          shape: BoxShape.circle,
          border: outlined ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5) : null,
        ),
        child: Icon(icon, color: iconColor ?? color ?? Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _ViewfinderCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    const radius = 4.0;
    final path = Path();

    // Top Left
    path.moveTo(0, len); path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0); path.lineTo(len, 0);

    // Top Right
    path.moveTo(size.width - len, 0); path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius); path.lineTo(size.width, len);

    // Bottom Left
    path.moveTo(0, size.height - len); path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height); path.lineTo(len, size.height);

    // Bottom Right
    path.moveTo(size.width - len, size.height); path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius); path.lineTo(size.width, size.height - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
