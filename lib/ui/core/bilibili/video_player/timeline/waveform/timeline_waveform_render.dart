import 'dart:math' as math;

import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/timeline_waveform_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';

class TimelineWaveformRender extends StatelessWidget {
  final TimelineWaveformController controller;

  const TimelineWaveformRender({super.key, required this.controller});

  String _generate(
    List<double> data, {
    double width = 2000,
    double height = 50,
    double paddingX = 4,
    double paddingY = 0,

    /// 控制数据的纵向压缩程度
    double exponent = 0.5,

    /// 波形
    String strokeColor = '#ffffff',
    double strokeWidth = 2,
    String strokeLinecap = 'round',
    String strokeLinejoin = 'round',

    /// 渐变
    String gradientId = 'waveFill',
    double gradientTopOpacity = 0.40,
    double gradientMiddleOpacity = 0.30,
    double gradientBottomOpacity = 0,
  }) {
    assert(data.isNotEmpty);

    String format(double value) => value.toStringAsFixed(2);

    String buildPath() {
      if (data.length == 1) {
        final y = height / 2;

        return 'M ${format(paddingX)} ${format(y)} '
            'L ${format(width - paddingX)} ${format(y)}';
      }

      var min = data.reduce(math.min);
      var max = data.reduce(math.max);

      // 避免除 0，并让波形位于中间
      if (min == max) {
        min -= 1;
        max += 1;
      }

      final usableWidth = width - paddingX * 2;
      final usableHeight = height - paddingY * 2;

      final points = <({double x, double y})>[];

      for (var index = 0; index < data.length; index++) {
        final value = data[index];

        final x = paddingX + (index / (data.length - 1)) * usableWidth;

        final normalized = math
            .pow(
              (value - min) / (max - min),
              exponent,
            )
            .toDouble();

        final y = height - paddingY - normalized * usableHeight;

        points.add((x: x, y: y));
      }

      /*
     * Monotone Cubic interpolation
     *
     * 为每个数据点计算一个切线斜率，
     * 再通过限制切线斜率避免 overshoot
     */

      final n = points.length;

      // 相邻点之间的割线斜率
      final delta = List<double>.filled(n - 1, 0);

      for (var i = 0; i < n - 1; i++) {
        final dx = points[i + 1].x - points[i].x;
        final dy = points[i + 1].y - points[i].y;

        delta[i] = dy / dx;
      }

      // 每个数据点的切线斜率
      final tangent = List<double>.filled(n, 0);

      // 两端点使用相邻线段的斜率
      tangent[0] = delta[0];
      tangent[n - 1] = delta[n - 2];

      // 内部点
      for (var i = 1; i < n - 1; i++) {
        final d1 = delta[i - 1];
        final d2 = delta[i];

        // 如果前后方向不同，说明这里是局部极值
        // 切线必须设为 0，避免 overshoot
        if (d1 * d2 <= 0) {
          tangent[i] = 0;
        } else {
          // 对不等间距点使用加权调和平均
          final h1 = points[i].x - points[i - 1].x;
          final h2 = points[i + 1].x - points[i].x;

          final w1 = 2 * h2 + h1;
          final w2 = h2 + 2 * h1;

          tangent[i] = (w1 + w2) / (w1 / d1 + w2 / d2);
        }
      }

      /*
     * 进一步限制切线，保证不会产生 overshoot
     *
     * 对每一段：
     *
     *   alpha = m0 / delta
     *   beta  = m1 / delta
     *
     * 如果 alpha^2 + beta^2 > 9，就整体缩小切线
     */
      for (var i = 0; i < n - 1; i++) {
        final d = delta[i];

        if (d == 0) {
          tangent[i] = 0;
          tangent[i + 1] = 0;
          continue;
        }

        final alpha = tangent[i] / d;
        final beta = tangent[i + 1] / d;

        final sum = alpha * alpha + beta * beta;

        if (sum > 9) {
          final tau = 3 / math.sqrt(sum);

          tangent[i] = tau * alpha * d;
          tangent[i + 1] = tau * beta * d;
        }
      }

      var d = 'M ${format(points[0].x)} ${format(points[0].y)}';

      for (var i = 0; i < n - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        final dx = (p2.x - p1.x) / 3;

        // Hermite -> Cubic Bézier
        final cp1 = (
          x: p1.x + dx,
          y: p1.y + tangent[i] * dx,
        );

        final cp2 = (
          x: p2.x - dx,
          y: p2.y - tangent[i + 1] * dx,
        );

        d +=
            ' C ${format(cp1.x)} ${format(cp1.y)}'
            ', ${format(cp2.x)} ${format(cp2.y)}'
            ', ${format(p2.x)} ${format(p2.y)}';
      }

      return d;
    }

    final d = buildPath();

    final fillD =
        '$d'
        ' L ${format(width - paddingX)} ${format(height)}'
        ' L ${format(paddingX)} ${format(height)}'
        ' Z';

    return '''
<svg viewBox="0 0 ${format(width)} ${format(height)}" preserveAspectRatio="none">
  <defs>
    <linearGradient id="$gradientId" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="white" stop-opacity="$gradientTopOpacity" />
      <stop offset="50%" stop-color="white" stop-opacity="$gradientMiddleOpacity" />
      <stop offset="100%" stop-color="white" stop-opacity="$gradientBottomOpacity" />
    </linearGradient>
  </defs>

  <path d="$fillD" fill="url(#$gradientId)" stroke="none" />

  <path
    d="$d"
    fill="none"
    stroke="$strokeColor"
    stroke-width="$strokeWidth"
    stroke-linecap="$strokeLinecap"
    stroke-linejoin="$strokeLinejoin"
    vector-effect="non-scaling-stroke"
  />
</svg>
'''
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.data.isEmpty) {
          return SizedBox.shrink();
        }

        return SizedBox(
          width: .infinity,
          height: 35,
          child: SvgPicture.string(
            _generate(controller.data),
            fit: .fill,
          ),
        );
      },
    );
  }
}
