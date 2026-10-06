import 'package:better_bilibili/utils/config_item.dart';
import 'package:flutter/material.dart';

class ConfigBuilder<T> extends StatelessWidget {
  final ConfigItem<T> configItem;
  final Widget Function(BuildContext context, T value) builder;

  const ConfigBuilder({super.key, required this.configItem, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: configItem.get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return StreamBuilder(
            stream: configItem.stream,
            builder: (context, snapshot) => builder(context, configItem.value),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
