import 'package:material_ui/material_ui.dart';

class RangeSliderPanelTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final RangeLabels? labels;
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  const RangeSliderPanelTile({
    super.key,
    required this.title,
    this.labels,
    this.subtitle,
    required this.values,
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
            child: RangeSlider(
              values: values,
              labels: labels,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (values) => onChanged?.call(
                RangeValues(
                  (values.start * 100).round() / 100.0,
                  (values.end * 100).round() / 100.0,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 6.0, 14.0),
            ),
          ),
        ],
      ),
    );
  }
}
