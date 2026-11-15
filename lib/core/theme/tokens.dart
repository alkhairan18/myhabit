import 'package:flutter/material.dart';

const seedColor = Color(0xFF3F51B5);

/// Mid-luminance so each reads >=3:1 on both light and dark surfaces.
const habitColors = <Color>[
  Color(0xFFE53935),
  Color(0xFFD81B60),
  Color(0xFFAB47BC),
  Color(0xFF5C6BC0),
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFF43A047),
  Color(0xFFE65100),
  Color(0xFF8D6E63),
];

const animFast = Duration(milliseconds: 200);


const habitIcons = <String, IconData>{
  'water': Icons.water_drop,
  'book': Icons.menu_book,
  'fitness': Icons.fitness_center,
  'run': Icons.directions_run,
  'study': Icons.school,
  'pray': Icons.self_improvement,
  'sleep': Icons.bedtime,
  'food': Icons.restaurant,
  'code': Icons.code,
  'music': Icons.music_note,
};

IconData iconFor(String name) => habitIcons[name] ?? Icons.check_circle_outline;
