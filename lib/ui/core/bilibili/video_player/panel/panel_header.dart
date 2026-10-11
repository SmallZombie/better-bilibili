import 'package:material_ui/material_ui.dart';

class PanelHeader extends StatelessWidget {
  final Widget title;
  final VoidCallback? onBack;

  const PanelHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: .symmetric(
            horizontal: 12.0 + (onBack != null ? -4.0 : 0.0),
            vertical: 12.0,
          ),
          child: Row(
            spacing: 4.0,
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.keyboard_arrow_left_rounded,
                    color: Colors.white70,
                  ),
                  visualDensity: .compact,
                  tooltip: '返回',
                ),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  child: title,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white12),
      ],
    );
  }
}
