import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/core/theme/app_theme.dart';
import 'package:rutin/core/theme/tokens.dart';

double contrast(Color a, Color b) {
  final l1 = a.computeLuminance(), l2 = b.computeLuminance();
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('8-10 habit colors', () {
    expect(habitColors.length, inInclusiveRange(8, 10));
  });
  test('every habit color has >=3:1 contrast on light and dark surfaces', () {
    for (final c in habitColors) {
      expect(contrast(c, lightTheme().colorScheme.surface), greaterThanOrEqualTo(3.0), reason: '$c light');
      expect(contrast(c, darkTheme().colorScheme.surface), greaterThanOrEqualTo(3.0), reason: '$c dark');
    }
  });
}
