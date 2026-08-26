import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:flutter/material.dart';

const kDefaultUserAvatar = 'https://i0.hdslb.com/bfs/face/member/noface.jpg';

class BiliImageWapper extends StatelessWidget {
  final String url;
  final String? suffix;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit fit;
  final double? aspectRatio;
  final Color? placeholderColor;

  const BiliImageWapper({
    super.key,
    required this.url,
    this.suffix,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.aspectRatio,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ImageWapper(
      image: NetworkImage(suffix != null ? '$url$suffix' : url),
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: fit,
      aspectRatio: aspectRatio,
      placeholderColor: placeholderColor,
    );
  }
}

/// recommendVideoCard 比 homeVideoCard 稍大一点
abstract class BiliImageSuffix {
  /// 首页视频卡片以及个人空间卡片使用的后缀
  /// 首页视频卡片原后缀 `@672w_378h_1c_!web-home-common-cover.avif`
  /// 个人空间卡片原后缀 `@672w_378h_1c.avif`
  static const String homeVideoCard = '@672w_378h_1c';

  /// 播放页推荐视频卡片以及新版历史记录使用的后缀
  /// 播放页推荐视频卡片原后缀 `@336w_190h_1c_!web-video-rcmd-cover.avif`
  /// 新版历史记录 `@760w_428h_1c.avif`
  static const String recommendVideoCard = '@760w_428h_1c';

  /// 自己通过 homeVideoCard / 2 得来的大小
  static const String small = '@336w_189h_1c';
}
