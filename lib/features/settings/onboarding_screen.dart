import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../habits/application/providers.dart';
import '../habits/data/habit_repository.dart';
import '../habits/domain/habit.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _selectedStarters = <String>{};

  Future<void> _finish(AppLocalizations l10n) async {
    if (_selectedStarters.isNotEmpty) {
      final repo = ref.read(habitRepositoryProvider);
      final today = ref.read(todayProvider);
      final starters = {
        'water': (l10n.starterWater, 'water', habitColors[4].toARGB32()),
        'read': (l10n.starterRead, 'book', habitColors[6].toARGB32()),
        'exercise': (l10n.starterExercise, 'fitness', habitColors[7].toARGB32()),
      };
      for (final key in ['water', 'read', 'exercise']) {
        if (_selectedStarters.contains(key)) {
          final s = starters[key]!;
          await repo.create(
            HabitDraft(
              name: s.$1,
              icon: s.$2,
              color: s.$3,
              frequencyType: FrequencyType.daily,
            ),
            createdAt: today,
          );
        }
      }
    }
    await ref.read(settingsRepositoryProvider).setOnboardingDone();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final pillars = [
      (Icons.check_circle_outline_rounded, l10n.onboardingPillar1),
      (Icons.local_fire_department_outlined, l10n.onboardingPillar2),
      (Icons.lock_outline_rounded, l10n.onboardingPillar3),
    ];
    final titles = [
      l10n.onboardingTitle,
      l10n.onboardingStep2Title,
      l10n.onboardingStep3Title,
    ];
    final bodies = [
      l10n.onboardingBody,
      l10n.onboardingStep2Body,
      l10n.onboardingStep3Body,
    ];
    final icons = [
      Icons.spa_outlined,
      Icons.insights_rounded,
      Icons.auto_awesome_outlined,
    ];
    final starterOptions = [
      ('water', 'starter-water', Icons.water_drop_outlined, l10n.starterWater),
      ('read', 'starter-read', Icons.menu_book_outlined, l10n.starterRead),
      ('exercise', 'starter-exercise', Icons.fitness_center_outlined, l10n.starterExercise),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: i == _step ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: i == _step ? cs.primary : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(rMicro),
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    key: const Key('skip-onboarding'),
                    onPressed: () => _finish(l10n),
                    child: Text(l10n.onboardingSkip),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(rCard),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(24),
                              borderRadius: BorderRadius.circular(rControl),
                            ),
                            child: Icon(icons[_step], size: 26, color: cs.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            titles[_step],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bodies[_step],
                            style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          if (_step < 2)
                            for (final (icon, text) in pillars)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                    Icon(icon, size: 18, color: cs.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        text,
                                        style: const TextStyle(fontSize: 13, height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final (id, keyName, icon, label) in starterOptions)
                                  FilterChip(
                                    key: Key(keyName),
                                    avatar: Icon(icon, size: 16),
                                    label: Text(label),
                                    selected: _selectedStarters.contains(id),
                                    onSelected: (on) => setState(() => on
                                        ? _selectedStarters.add(id)
                                        : _selectedStarters.remove(id)),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_step < 2) ...[
                    OutlinedButton(
                      key: const Key('next-onboarding'),
                      onPressed: () => setState(() => _step++),
                      child: Text(l10n.onboardingNext),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      key: const Key('start-onboarding'),
                      onPressed: () => _finish(l10n),
                      child: Text(l10n.onboardingStart),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
