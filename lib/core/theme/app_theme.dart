import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData _theme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: b),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

ThemeData lightTheme() => _theme(Brightness.light);
ThemeData darkTheme() => _theme(Brightness.dark);
