import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';

abstract interface class TimelinePreviewController implements Listenable {
  Future<void> updatePreview(Duration position);
  ui.Image? get currentImage;
  Rect? get currentRect;
}
