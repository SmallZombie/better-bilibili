import 'package:flutter/material.dart';

enum DanmakuType {
  scroll,
  top,
  bottom,
  advanced,
}

class Danmaku {
  final DanmakuType type;
  final String text;
  final String cleanText;
  final int time;
  final Color color;
  final int size;
  final ExtraAnimation? extra;

  const Danmaku({
    required this.type,
    required this.text,
    required this.cleanText,
    required this.time,
    required this.color,
    required this.size,
    this.extra,
  });
}

class ExtraAnimation {
  final double beginX;
  final double beginY;
  final double endX;
  final double endY;
  final double beginAlpha;
  final double endAlpha;
  final Duration alphaDuration;
  final Duration translationDuration;
  final Duration translationStartDelay;
  final double rotateY;
  final double rotateZ;
  final Duration duration;
  final bool border;
  final String? fontFamily;
  final bool isQuadraticEaseOut;

  const ExtraAnimation({
    required this.beginX,
    required this.beginY,
    required this.endX,
    required this.endY,
    required this.beginAlpha,
    required this.endAlpha,
    required this.alphaDuration,
    required this.translationDuration,
    required this.translationStartDelay,
    required this.rotateY,
    required this.rotateZ,
    required this.duration,
    required this.border,
    this.fontFamily,
    required this.isQuadraticEaseOut,
  });

  @override
  String toString() {
    return 'ExtraAnimation('
        'beginX: $beginX, '
        'beginY: $beginY, '
        'endX: $endX, '
        'endY: $endY, '
        'beginAlpha: $beginAlpha, '
        'endAlpha: $endAlpha, '
        'alphaDuration: $alphaDuration, '
        'translationDuration: $translationDuration, '
        'translationStartDelay: $translationStartDelay, '
        'rotateY: $rotateY, '
        'rotateZ: $rotateZ, '
        'duration: $duration, '
        'border: $border, '
        'fontFamily: $fontFamily, '
        'isQuadraticEaseOut: $isQuadraticEaseOut'
        ')';
  }
}
