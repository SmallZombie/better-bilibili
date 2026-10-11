import 'package:material_ui/material_ui.dart';

class PanelSectionTitle extends StatelessWidget {
  final String? title;

  const PanelSectionTitle({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(16.0, 16.0, 0.0, 6.0),
      child: title != null
          ? Text(
              title!,
              style: TextStyle(color: Colors.white70, fontSize: 12.0),
            )
          : SizedBox.shrink(),
    );
  }
}
