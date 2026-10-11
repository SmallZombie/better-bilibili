import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const ColorTest());
}

class ColorTest extends StatelessWidget {
  const ColorTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorScheme Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ColorSchemePage(),
    );
  }
}

class ColorSchemePage extends StatelessWidget {
  const ColorSchemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final colors = <String, Color>{
      'primary': colorScheme.primary,
      'onPrimary': colorScheme.onPrimary,
      'primaryContainer': colorScheme.primaryContainer,
      'onPrimaryContainer': colorScheme.onPrimaryContainer,

      'secondary': colorScheme.secondary,
      'onSecondary': colorScheme.onSecondary,
      'secondaryContainer': colorScheme.secondaryContainer,
      'onSecondaryContainer': colorScheme.onSecondaryContainer,

      'tertiary': colorScheme.tertiary,
      'onTertiary': colorScheme.onTertiary,
      'tertiaryContainer': colorScheme.tertiaryContainer,
      'onTertiaryContainer': colorScheme.onTertiaryContainer,

      'error': colorScheme.error,
      'onError': colorScheme.onError,
      'errorContainer': colorScheme.errorContainer,
      'onErrorContainer': colorScheme.onErrorContainer,

      'surface': colorScheme.surface,
      'onSurface': colorScheme.onSurface,

      'surfaceDim': colorScheme.surfaceDim,
      'surfaceBright': colorScheme.surfaceBright,

      'surfaceContainerLowest': colorScheme.surfaceContainerLowest,
      'surfaceContainerLow': colorScheme.surfaceContainerLow,
      'surfaceContainer': colorScheme.surfaceContainer,
      'surfaceContainerHigh': colorScheme.surfaceContainerHigh,
      'surfaceContainerHighest': colorScheme.surfaceContainerHighest,

      'onSurfaceVariant': colorScheme.onSurfaceVariant,

      'outline': colorScheme.outline,
      'outlineVariant': colorScheme.outlineVariant,

      'shadow': colorScheme.shadow,
      'scrim': colorScheme.scrim,

      'inverseSurface': colorScheme.inverseSurface,
      'onInverseSurface': colorScheme.onInverseSurface,
      'inversePrimary': colorScheme.inversePrimary,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorScheme Preview'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final entry = colors.entries.elementAt(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ColorTile(
              name: entry.key,
              color: entry.value,
            ),
          );
        },
      ),
    );
  }
}

class ColorTile extends StatelessWidget {
  final String name;
  final Color color;

  const ColorTile({
    super.key,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(color);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: TextStyle(
              color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
