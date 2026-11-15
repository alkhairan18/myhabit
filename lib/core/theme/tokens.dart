import 'package:flutter/material.dart';

const seedColor = Color(0xFF1B6B45);
const accentAmber = Color(0xFFD97706);
const accentAmberDark = Color(0xFFF59E0B);

const lightBg = Color(0xFFFAF7F2);
const lightCard = Color(0xFFFFFFFF);
const lightContainer = Color(0xFFF2EDE4);
const lightBorder = Color(0xFFE5DEC9);

const darkBg = Color(0xFF111513);
const darkCard = Color(0xFF1A201D);
const darkContainer = Color(0xFF242C28);
const darkBorder = Color(0xFF2E3833);

const rMicro = 4.0;
const rControl = 12.0;
const rCard = 16.0;

/// Mid-luminance swatches so each reads >=3:1 on both light and dark surfaces.
const habitColors = <Color>[
  Color(0xFFE53935),
  Color(0xFFD81B60),
  Color(0xFF9C42B0),
  Color(0xFF5C6BC0),
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFF43A047),
  Color(0xFFE65100),
  Color(0xFF8D6E63),
];

const habitColorNames = <String>[
  'Crimson',
  'Rose',
  'Plum',
  'Indigo',
  'Ocean',
  'Teal',
  'Forest',
  'Amber',
  'Earth',
];

const animFast = Duration(milliseconds: 200);

const habitIcons = <String, IconData>{
  'water': Icons.water_drop_outlined,
  'book': Icons.menu_book_outlined,
  'fitness': Icons.fitness_center_outlined,
  'run': Icons.directions_run_outlined,
  'study': Icons.school_outlined,
  'pray': Icons.self_improvement_outlined,
  'sleep': Icons.bedtime_outlined,
  'food': Icons.restaurant_outlined,
  'code': Icons.code_outlined,
  'music': Icons.music_note_outlined,
};

IconData iconFor(String name) => habitIcons[name] ?? Icons.check_circle_outline;
