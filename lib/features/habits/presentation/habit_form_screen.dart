import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../reminders/data/notification_service.dart';
import '../../reminders/presentation/reminder_permission_sheet.dart';
import '../application/providers.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_validation.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});
  final int? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _State();
}

class _State extends ConsumerState<HabitFormScreen> {
  final _name = TextEditingController();
  final _target = TextEditingController(text: '3');
  String _icon = habitIcons.keys.first;
  int _color = habitColors.first.toARGB32();
  FrequencyType _type = FrequencyType.daily;
  final _days = <int>{};
  var _reminders = <ReminderTime>[];
  var _errors = <HabitError>{};
  Habit? _existing;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final id = widget.habitId;
    if (id != null) {
      _loading = true;
      _load(id);
    }
  }

  Future<void> _load(int id) async {
    final repo = ref.read(habitRepositoryProvider);
    final h = await repo.getHabit(id);
    final rs = await repo.remindersFor(id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (h != null) {
        _existing = h;
        _name.text = h.name;
        _icon = h.icon;
        _color = h.color;
        _type = h.frequencyType;
        _days
          ..clear()
          ..addAll(h.frequencyDays);
        _target.text = '${h.targetPerWeek ?? 3}';
        _reminders = rs;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  void _leave() => context.canPop() ? context.pop() : context.go('/');

  Future<void> _save() async {
    final target = int.tryParse(_target.text);
    final errs = validateHabit(
        name: _name.text, type: _type, days: _days, target: target);
    if (errs.isNotEmpty) {
      setState(() => _errors = errs);
      return;
    }
    final draft = HabitDraft(
      name: _name.text.trim(),
      description: _existing?.description,
      icon: _icon,
      color: _color,
      frequencyType: _type,
      frequencyDays: _type == FrequencyType.specificDays ? _days : const {},
      targetPerWeek: _type == FrequencyType.timesPerWeek ? target : null,
    );
    final repo = ref.read(habitRepositoryProvider);
    final id = widget.habitId;
    if (id == null) {
      await repo.create(draft,
          createdAt: ref.read(todayProvider), reminders: _reminders);
    } else {
      await repo.update(id, draft, reminders: _reminders);
    }
    final syncRes = await syncReminders(ref);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (syncRes == ReminderSyncResult.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.permDenied)),
      );
    } else if (syncRes == ReminderSyncResult.exactAlarmDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.permExactDenied)),
      );
    }
    _leave();
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          TextButton(
              key: const Key('confirm-delete'),
              onPressed: () => Navigator.pop(c, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(habitRepositoryProvider).delete(widget.habitId!);
      await syncReminders(ref);
      if (mounted) context.go('/');
    }
  }

  Future<void> _addReminder() async {
    if (_reminders.isEmpty && !await showReminderPermissionSheet(context)) return;
    if (!mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (t != null) {
      setState(() => _reminders = [..._reminders, ReminderTime(t.hour, t.minute)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final editing = widget.habitId != null;
    final isArchived = _existing?.archivedAt != null;
    final cs = Theme.of(context).colorScheme;
    Widget error(String s) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(s, style: TextStyle(color: cs.error, fontSize: 12)));
    Widget sectionLabel(String s) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            s,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l10n.editHabit : l10n.newHabit),
        actions: [
          if (editing) ...[
            IconButton(
              key: const Key('archive'),
              tooltip: isArchived ? l10n.unarchive : l10n.archive,
              icon: Icon(isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
              onPressed: () async {
                final repo = ref.read(habitRepositoryProvider);
                if (isArchived) {
                  await repo.unarchive(widget.habitId!);
                } else {
                  await repo.archive(widget.habitId!, ref.read(todayProvider));
                }
                await syncReminders(ref);
                if (mounted) _leave();
              },
            ),
            IconButton(
              key: const Key('delete'),
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(l10n),
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                TextField(
                  key: const Key('name'),
                  controller: _name,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    hintText: l10n.nameHint,
                    prefixIcon: Icon(iconFor(_icon), color: Color(_color)),
                    errorText: _errors.contains(HabitError.nameEmpty)
                        ? l10n.errNameEmpty
                        : _errors.contains(HabitError.nameTooLong)
                            ? l10n.errNameTooLong
                            : null,
                  ),
                ),
                sectionLabel(l10n.iconSectionLabel),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in habitIcons.entries)
                    Semantics(
                      label: 'Icon ${e.key}',
                      selected: _icon == e.key,
                      button: true,
                      child: ChoiceChip(
                        label: Icon(e.value, semanticLabel: e.key),
                        selected: _icon == e.key,
                        onSelected: (_) => setState(() => _icon = e.key),
                      ),
                    ),
                ]),
                sectionLabel(l10n.colorSectionLabel),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (var i = 0; i < habitColors.length; i++)
                    Semantics(
                      label: 'Color ${habitColorNames[i]}',
                      selected: _color == habitColors[i].toARGB32(),
                      button: true,
                      excludeSemantics: true,
                      child: InkResponse(
                        onTap: () =>
                            setState(() => _color = habitColors[i].toARGB32()),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: habitColors[i],
                            shape: BoxShape.circle,
                            border: _color == habitColors[i].toARGB32()
                                ? Border.all(color: cs.onSurface, width: 2.5)
                                : null,
                          ),
                          child: _color == habitColors[i].toARGB32()
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                ]),
                sectionLabel(l10n.frequencySectionLabel),
                SegmentedButton<FrequencyType>(
                  segments: [
                    ButtonSegment(value: FrequencyType.daily, label: Text(l10n.freqDaily)),
                    ButtonSegment(value: FrequencyType.specificDays, label: Text(l10n.freqDays)),
                    ButtonSegment(value: FrequencyType.timesPerWeek, label: Text(l10n.freqWeekly)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                if (_type == FrequencyType.specificDays) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (var wd = 1; wd <= 7; wd++)
                      FilterChip(
                        // 2026-11-09 is a Monday, so weekday wd falls on day 8 + wd.
                        label: Text(DateFormat.E(locale).format(DateTime.utc(2026, 11, 8 + wd))),
                        selected: _days.contains(wd),
                        onSelected: (on) =>
                            setState(() => on ? _days.add(wd) : _days.remove(wd)),
                      ),
                  ]),
                  if (_errors.contains(HabitError.noDaysSelected)) error(l10n.errNoDays),
                ],
                if (_type == FrequencyType.timesPerWeek) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('target'),
                    controller: _target,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l10n.targetLabel),
                  ),
                  if (_errors.contains(HabitError.invalidWeeklyTarget))
                    error(l10n.errTarget),
                ],
                sectionLabel(l10n.reminders),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final r in _reminders)
                    InputChip(
                      label: Text(
                        r.toHm(),
                        style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      onDeleted: () =>
                          setState(() => _reminders = [..._reminders]..remove(r)),
                    ),
                  ActionChip(
                      avatar: const Icon(Icons.add_alarm, size: 18),
                      label: Text(l10n.addReminder),
                      onPressed: _addReminder),
                ]),
                const SizedBox(height: 28),
                FilledButton(
                    key: const Key('save'),
                    onPressed: _save,
                    child: Text(l10n.save)),
              ],
            ),
          ),
    );
  }
}
