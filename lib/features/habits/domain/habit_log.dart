class HabitLog {
  const HabitLog({
    required this.habitId,
    required this.date,
    required this.completed,
    this.note,
  });

  final int habitId;
  final DateTime date;
  final bool completed;
  final String? note;
}
