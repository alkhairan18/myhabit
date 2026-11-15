typedef Clock = DateTime Function();

/// Date-only value as UTC midnight (immune to DST).
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String toIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseIso(String s) {
  final p = s.split('-');
  if (p.length != 3) throw const FormatException('Invalid ISO date');
  final y = int.parse(p[0]), m = int.parse(p[1]), d = int.parse(p[2]);
  if (m < 1 || m > 12 || d < 1 || d > 31) {
    throw const FormatException('Date out of range');
  }
  return DateTime.utc(y, m, d);
}

DateTime weekStart(DateTime d, {int weekStartsOn = DateTime.monday}) {
  final back = (d.weekday - weekStartsOn + 7) % 7;
  return DateTime.utc(d.year, d.month, d.day - back);
}
