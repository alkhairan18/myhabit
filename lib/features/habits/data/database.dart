import 'package:drift/drift.dart';

part 'database.g.dart';

@DataClassName('HabitRow')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  TextColumn get frequencyType => text()();
  TextColumn get frequencyDays => text().withDefault(const Constant(''))();
  IntColumn get targetPerWeek => integer().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAt => text()();
  TextColumn get archivedAt => text().nullable()();
}

@DataClassName('HabitLogRow')
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text()();
  BoolColumn get completed => boolean()();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, date}
      ];
}

@DataClassName('ReminderEntity')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get time => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Habits, HabitLogs, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );
}
