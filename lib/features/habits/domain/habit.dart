enum FrequencyType { daily, specificDays, timesPerWeek }

class Habit {
  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.frequencyType,
    this.frequencyDays = const {},
    this.targetPerWeek,
    required this.sortOrder,
    required this.createdAt,
    this.archivedAt,
  });

  final int id;
  final String name;
  final String? description;
  final String icon;
  final int color;
  final FrequencyType frequencyType;

  /// DateTime.monday..DateTime.sunday
  final Set<int> frequencyDays;
  final int? targetPerWeek;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? archivedAt;
}
