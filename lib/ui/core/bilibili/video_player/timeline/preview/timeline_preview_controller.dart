import 'dart:ui' as ui;
import 'package:flutter/material.dart';

abstract interface class TimelinePreviewController implements Listenable {
  Future<void> updatePreview(Duration position);
  ui.Image? get currentImage;
  Rect? get currentRect;
}
