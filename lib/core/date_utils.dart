typedef Clock = DateTime Function();

/// Date-only value as UTC midnight (immune to DST).
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String toIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseIso(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]);
}

DateTime weekStart(DateTime d, {int weekStartsOn = DateTime.monday}) {
  final back = (d.weekday - weekStartsOn + 7) % 7;
  return DateTime.utc(d.year, d.month, d.day - back);
}
