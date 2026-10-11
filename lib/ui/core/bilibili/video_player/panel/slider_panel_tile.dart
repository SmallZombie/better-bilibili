import 'package:material_ui/material_ui.dart';

class SliderPanelTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final String? label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  const SliderPanelTile({
    super.key,
    required this.title,
    this.label,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              spacing: 2.0,
              children: [
                DefaultTextStyle.merge(
                  style: TextStyle(color: Colors.white, fontSize: 12.5),
                  child: title,
                ),
                if (subtitle != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          Transform.scale(
            scale: .85,
            child: Slider(
              value: value,
              label: label,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (value) => onChanged?.call((value * 100).round() / 100.0),
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 6.0, 14.0),
            ),
          ),
        ],
      ),
    );
  }
}
