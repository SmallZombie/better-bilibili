import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_tile.dart';
import 'package:flutter/material.dart';

class SelectionPanelItem<T> {
  final String label;
  final T value;

  const SelectionPanelItem({required this.label, required this.value});
}

class SelectionPanel<T> extends StatelessWidget {
  final PanelHeader header;
  final List<SelectionPanelItem<T>> items;
  final T value;
  final ValueChanged<T> onChange;

  const SelectionPanel({
    super.key,
    required this.header,
    required this.items,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        header,
        Expanded(
          child: ListView(
            children: items.map(
              (v) {
                return PanelTile(
                  onTap: v.value == value ? () {} : () => onChange(v.value),
                  selected: v.value == value,
                  title: Text(v.label),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
