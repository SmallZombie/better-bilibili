import 'package:flutter/material.dart';

abstract interface class TimelineWaveformController implements Listenable {
  List<double> get data;
}
