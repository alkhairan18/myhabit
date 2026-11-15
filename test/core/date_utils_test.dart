import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/core/date_utils.dart';

void main() {
  test('toIso formats yyyy-MM-dd', () {
    expect(toIso(DateTime.utc(2026, 1, 5)), '2026-01-05');
  });
  test('parseIso returns UTC date-only', () {
    expect(parseIso('2026-12-31'), DateTime.utc(2026, 12, 31));
  });
  test('weekStart Monday for a Sunday', () {
    expect(weekStart(DateTime.utc(2026, 11, 15)), DateTime.utc(2026, 11, 9));
  });
  test('weekStart with Sunday start', () {
    expect(weekStart(DateTime.utc(2026, 11, 15), weekStartsOn: DateTime.sunday),
        DateTime.utc(2026, 11, 15));
  });
  test('dateOnly drops time', () {
    expect(dateOnly(DateTime(2026, 3, 1, 23, 59)), DateTime.utc(2026, 3, 1));
  });
}
