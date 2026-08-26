import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AmbientLightLayer extends StatelessWidget {
  final VideoController controller;
  final double width;
  final double height;

  const AmbientLightLayer({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
  });

  // [saturation]: 饱和度倍率
  // [brightness]: 亮度倍率
  List<double> _calcMatrix({required double saturation, required double brightness}) {
    // Rec.709
    const double rLum = 0.2126;
    const double gLum = 0.7152;
    const double bLum = 0.0722;

    final double sr = (1 - saturation) * rLum;
    final double sg = (1 - saturation) * gLum;
    final double sb = (1 - saturation) * bLum;

    // dart format off
    return <double>[
      (sr + saturation) * brightness, sg * brightness, sb * brightness, 0, 0,
      sr * brightness, (sg + saturation) * brightness, sb * brightness, 0, 0,
      sr * brightness, sg * brightness, (sb + saturation) * brightness, 0, 0,
      0, 0, 0, 1, 0,
    ];
    // dart format on
  }

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: height / 16,
        sigmaY: width / 16,
        tileMode: TileMode.decal,
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_calcMatrix(saturation: 3, brightness: 0.5)),
        child: Video(controller: controller),
      ),
    );
  }
}
