import 'package:material_ui/material_ui.dart';

abstract interface class Panel {
  String get id;
  Widget build(BuildContext context);
  double get width => 310;
}
