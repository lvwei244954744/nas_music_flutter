extension DurationFormat on Duration {
  String toMMSS() {
    final min = inMinutes;
    final sec = inSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

String formatSeconds(int seconds) {
  final min = seconds ~/ 60;
  final sec = seconds % 60;
  return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}
