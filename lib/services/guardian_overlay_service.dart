import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class GuardianOverlayService {
  GuardianOverlayService._();

  static bool _starting = false;

  static Future<void> ensureStarted() async {
    if (!Platform.isAndroid || _starting) return;

    _starting = true;
    try {
      var granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) {
        granted = await FlutterOverlayWindow.requestPermission() ?? false;
      }
      if (!granted) return;

      final active = await FlutterOverlayWindow.isActive();
      if (active) return;

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'Shakti Guardian',
        overlayContent: 'Emergency bubble active',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: 210,
        width: 260,
      );
    } catch (e) {
      debugPrint('Guardian overlay unavailable: $e');
    } finally {
      _starting = false;
    }
  }
}
