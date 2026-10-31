import 'package:material_ui/material_ui.dart';
import 'package:silky_scroll/silky_scroll.dart';

@Deprecated('')
const BorderRadius kInfiniteBorderRadius = BorderRadius.all(Radius.circular(999));

const kDefaultSilkyConfig = SilkyScrollConfig(
  silkyScrollDuration: Duration(milliseconds: 400),
  animationCurve: Curves.bounceOut,
);
