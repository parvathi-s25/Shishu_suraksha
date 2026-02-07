import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';
import 'package:shishu_suraksha/ui/screens/auth/authentication_screen.dart';

class PermissionRequestScreen extends StatefulWidget {
  final String selectedLanguage;
  const PermissionRequestScreen({super.key, required this.selectedLanguage});

  @override
  State<PermissionRequestScreen> createState() => _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  // Track permission states
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _microphoneStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  // PermissionStatus _photosStatus = PermissionStatus.denied; // For Android 13+ usually distinct

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    final notification = await Permission.notification.status;

    if (mounted) {
      setState(() {
        _cameraStatus = camera;
        _microphoneStatus = mic;
        _notificationStatus = notification;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    _checkPermissions(); // Refresh UI
  }

  Future<void> _requestAll() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ].request();
    _checkPermissions();
  }

  void _continueToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          selectedLanguage: widget.selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _cameraStatus.isGranted && 
                       _microphoneStatus.isGranted && 
                       _notificationStatus.isGranted;

    return Scaffold(
      body: Stack(
        children: [
          // Background
           Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permissions Required',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To provide the best screening and care features, Shishu Suraksha AI needs access to:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildPermissionItem(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    description: 'Required for visual screening and posture analysis.',
                    status: _cameraStatus,
                    onTap: () => _requestPermission(Permission.camera),
                  ),
                  const SizedBox(height: 16),

                  _buildPermissionItem(
                    icon: Icons.mic,
                    title: 'Microphone',
                    description: 'Required for audio screening and cry analysis.',
                    status: _microphoneStatus,
                    onTap: () => _requestPermission(Permission.microphone),
                  ),
                  const SizedBox(height: 16),

                  _buildPermissionItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    description: 'To remind you about schedules and alerts.',
                    status: _notificationStatus,
                    onTap: () => _requestPermission(Permission.notification),
                  ),

                  const Spacer(),

                  // Action Buttons
                  if (!allGranted)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _requestAll,
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Allow All'),
                      ),
                    ),
                  
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _continueToAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allGranted ? AppColors.secondary : Colors.white24,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(allGranted ? 'Continue' : 'Skip for Now'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
    required VoidCallback onTap,
  }) {
    final isGranted = status.isGranted;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGranted ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check : icon,
              color: isGranted ? Colors.greenAccent : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onTap,
              child: const Text('Allow', style: TextStyle(color: AppColors.secondary)),
            ),
        ],
      ),
    );
  }
}
