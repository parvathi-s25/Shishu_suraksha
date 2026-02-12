import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  static const String _permissionsRequestedKey = 'permissions_requested_v1';

  /// Triggers the permission request flow if it hasn't been completed yet.
  static Future<void> requestInitialPermissions(BuildContext context) async {
    // List of permissions to request sequentially
    // Sequence: Camera -> Microphone -> Audio -> Media / Storage -> Phone Call -> Notifications
    List<Permission> permissions = [];

    // 1. Camera
    permissions.add(Permission.camera);

    // 2. Microphone
    permissions.add(Permission.microphone);

    // 3. Audio & 4. Media/Storage
    // Platform check: kIsWeb must be checked first because Platform.isAndroid throws on Web
    if (!kIsWeb && Platform.isAndroid) {
      // Android 13+ (SDK 33) permissions
      // Audio
      permissions.add(Permission.audio);
      
      // Media / Storage
      // Ideally check SDK version, but adding all safe ones 
      permissions.add(Permission.photos);
      permissions.add(Permission.videos);
      
      // Legacy Storage (Android < 13)
      permissions.add(Permission.storage);
    } else if (!kIsWeb && (Platform.isIOS)) {
      // iOS
      permissions.add(Permission.audio); 
      permissions.add(Permission.storage);
    }
    // On Web/Desktop, we might not need these or handle differently. 
    // permission_handler mostly supports mobile.

    // 5. Phone Call
    if (!kIsWeb) {
      permissions.add(Permission.phone);
    }

    // 6. Notifications
    permissions.add(Permission.notification);

    // Request permissions sequentially
    for (var permission in permissions) {
      // Check status first
      // We do NOT check _hasRunThisSession here to ensure if a permission is MISSING, we try to ask.
      // permission_handler's .request() is smart enough not to show a dialog if already granted.
      // It also won't show if permanently denied (system behavior).
      var status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    }
  }
}
