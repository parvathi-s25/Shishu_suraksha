import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';

class ThermalScreeningScreen extends StatefulWidget {
  const ThermalScreeningScreen({super.key});

  @override
  State<ThermalScreeningScreen> createState() => _ThermalScreeningScreenState();
}

class _ThermalScreeningScreenState extends State<ThermalScreeningScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  double _simulatedTemperature = 36.5;
  String _temperatureStatus = 'Normal';
  Color _statusColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _simulateTemperatureReading();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera available')),
          );
        }
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  void _simulateTemperatureReading() {
    // Simulate temperature readings (in production, this would come from thermal camera hardware)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // Random temperature between 35.5 and 38.5
          _simulatedTemperature = 35.5 + (3.0 * (DateTime.now().millisecond % 100) / 100);
          
          if (_simulatedTemperature < 37.5) {
            _temperatureStatus = 'Normal';
            _statusColor = Colors.green;
          } else if (_simulatedTemperature < 38.0) {
            _temperatureStatus = 'Elevated';
            _statusColor = Colors.orange;
          } else {
            _temperatureStatus = 'High';
            _statusColor = Colors.red;
          }
        });
        _simulateTemperatureReading();
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final image = await _cameraController!.takePicture();
      
      // Simulate analysis delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showResultDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.thermostat, color: _statusColor, size: 32),
            const SizedBox(width: 12),
            const Text('Screening Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Temperature', '${_simulatedTemperature.toStringAsFixed(1)}°C'),
            _buildResultRow('Status', _temperatureStatus),
            _buildResultRow('Time', TimeOfDay.now().format(context)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _temperatureStatus == 'Normal' 
                        ? Icons.check_circle 
                        : Icons.warning,
                    color: _statusColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _temperatureStatus == 'Normal'
                          ? 'Child temperature is within normal range'
                          : 'Elevated temperature detected. Consider medical consultation.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Save result to database
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Result'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Thermal Overlay Effect
          if (_isInitialized)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.transparent,
                      _statusColor.withOpacity(0.1),
                      _statusColor.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Thermal Screening',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Thermal Screening'),
                            content: const Text(
                              'This feature simulates thermal camera screening. '
                              'In production, it would integrate with actual thermal camera hardware '
                              'to measure body temperature accurately.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Temperature Display
          if (_isInitialized)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.thermostat, color: _statusColor, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            '${_simulatedTemperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor),
                        ),
                        child: Text(
                          _temperatureStatus,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Center Target Reticle
          if (_isInitialized)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: _statusColor, width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  children: [
                    // Corner markers
                    ...List.generate(4, (index) {
                      return Positioned(
                        top: index < 2 ? 10 : null,
                        bottom: index >= 2 ? 10 : null,
                        left: index % 2 == 0 ? 10 : null,
                        right: index % 2 == 1 ? 10 : null,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: index < 2
                                  ? BorderSide(color: _statusColor, width: 3)
                                  : BorderSide.none,
                              bottom: index >= 2
                                  ? BorderSide(color: _statusColor, width: 3)
                                  : BorderSide.none,
                              left: index % 2 == 0
                                  ? BorderSide(color: _statusColor, width: 3)
                                  : BorderSide.none,
                              right: index % 2 == 1
                                  ? BorderSide(color: _statusColor, width: 3)
                                  : BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Position child\'s face in the center',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Capture Button
                        GestureDetector(
                          onTap: _isCapturing ? null : _captureAndAnalyze,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCapturing 
                                  ? Colors.grey 
                                  : AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),
                        ),
                      ],
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
}
