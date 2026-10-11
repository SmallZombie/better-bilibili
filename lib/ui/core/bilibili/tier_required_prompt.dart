import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:material_ui/material_ui.dart';

class TierRequiredPrompt extends StatelessWidget {
  final SubscriptionTier requiredTier;

  const TierRequiredPrompt({super.key, required this.requiredTier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('订阅会员以解锁此内容和更多内容'),
          Text(
            requiredTier.name,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
          Text(
            '${requiredTier.price} ${requiredTier.currency} / 月',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          // 闪电图标
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.flash_on_rounded),
            label: const Text('立即加入'),
          ),
        ],
      ),
    );
  }
}
