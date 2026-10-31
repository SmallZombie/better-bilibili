import 'package:better_bilibili/data/services/bilibili/model/get_following_users.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  final FollowingUser user;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .all(12.0),
          child: Row(
            mainAxisSize: .min,
            spacing: 8.0,
            children: [
              BiliUserAvatar(
                url: user.avatar,
                size: 72,
                isVerified: user.isVerified,
                isEnterpriseVerified: user.isEnterpriseVerified,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Row(
                      spacing: 8.0,
                      children: [
                        Text(
                          user.nickname,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        if (user.amEarlyFan)
                          ImageWapper(
                            image: AssetImage('assets/images/am_early_fan_icon.png'),
                            height: 14.0,
                          ),
                      ],
                    ),
                    if (user.description != null)
                      Text(
                        user.description!,
                        maxLines: 2,
                        overflow: .ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                  ],
                ),
              ),
              ChangeNotifierProvider(
                create: (context) => FollowTextButtonViewModel(
                  userRepository: context.read(),
                  userId: user.id,
                  initState: user.isFollowing,
                ),
                builder: (context, _) => FollowTextButton(viewModel: context.read()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
