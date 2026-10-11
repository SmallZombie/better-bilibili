import 'dart:math';

import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BiliUserAvatar extends StatelessWidget {
  final String url;
  final ImageProvider? frameImage;
  final double size;
  final bool isVip;
  final bool isVerified;
  final bool isEnterpriseVerified;
  final String suffix;

  const BiliUserAvatar({
    super.key,
    required this.url,
    this.frameImage,
    this.size = 48, // 96,
    this.isVip = false,
    this.isVerified = false,
    this.isEnterpriseVerified = false,
    this.suffix = '@80w_80h_1c_1s',
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = BiliImageWapper(
      url: url,
      suffix: suffix,
      borderRadius: kInfiniteBorderRadius,
      width: .infinity,
      height: .infinity,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          frameImage == null
              ? avatarWidget
              : Padding(
                  padding: EdgeInsets.all(size / 5),
                  child: avatarWidget,
                ),
          if (frameImage != null) ImageWapper(image: frameImage!),
          Positioned(
            bottom: frameImage == null ? -2 : size / 6,
            right: frameImage == null ? -2 : size / 6,
            child: Wrap(
              spacing: 2.0,
              children: [
                // 知名认证
                if (isVerified)
                  SvgPicture.asset(
                    'assets/images/verified_icon.svg',
                    width: max(size / 6, 18),
                    height: max(size / 6, 18),
                  ),

                // 企业认证
                if (isEnterpriseVerified)
                  SvgPicture.asset(
                    'assets/images/organization_verified_icon.svg',
                    width: max(size / 6, 18),
                    height: max(size / 6, 18),
                  ),

                // 会员
                if (isVip)
                  SvgPicture.asset(
                    'assets/images/vip_icon.svg',
                    width: max(size / 6, 18),
                    height: max(size / 6, 18),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
