import 'package:material_ui/material_ui.dart';

abstract interface class TimelineWaveformController implements Listenable {
  List<double> get data;
}
