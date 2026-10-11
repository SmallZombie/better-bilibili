import 'package:better_bilibili/config/constants.dart';
import 'package:material_ui/material_ui.dart';

/// 一个集缓存、比例、大小、圆角、加载动画为一体的图片组件
class ImageWapper extends StatelessWidget {
  final ImageProvider<Object> image;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角
  final BorderRadiusGeometry? borderRadius;

  /// 裁剪模式
  final BoxFit fit;

  /// 宽高比
  final double? aspectRatio;

  /// 占位/加载时的颜色
  final Color? placeholderColor;

  final int retryCount;

  /// 对齐方式
  final AlignmentGeometry alignment;

  const ImageWapper({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.aspectRatio,
    this.placeholderColor,
    this.retryCount = 3,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget widget = Image(
      image: image,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;

        return Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            if (frame == null)
              Positioned.fill(
                child: ColoredBox(
                  color: placeholderColor ?? colorScheme.surfaceContainerLow,
                ),
              ),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (retryCount <= 0) {
          return Image.network(kUnavailableImageUrl, fit: BoxFit.cover);
        }

        debugPrint('WrappedImage error: $error, retryCount: $retryCount');
        return ImageWapper(
          image: image,
          width: width,
          height: height,
          borderRadius: borderRadius,
          fit: fit,
          aspectRatio: aspectRatio,
          placeholderColor: placeholderColor,
          retryCount: retryCount - 1,
        );
      },
    );

    if (aspectRatio != null) {
      widget = SizedBox(
        width: width,
        height: height,
        child: AspectRatio(
          aspectRatio: aspectRatio!,
          child: widget,
        ),
      );
    }

    if (borderRadius != null) {
      widget = ClipRRect(
        borderRadius: borderRadius!,
        child: widget,
      );
    }

    return widget;
  }
}
