extension DurationUtil on Duration {
  bool isCloseTo(Duration target, [Duration tolerance = const Duration(milliseconds: 100)]) {
    return (this - target).abs() <= tolerance;
  }
}
