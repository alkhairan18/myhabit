import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../habits/application/providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final pillars = [
      (Icons.check_circle_outline_rounded, l10n.onboardingPillar1),
      (Icons.local_fire_department_outlined, l10n.onboardingPillar2),
      (Icons.lock_outline_rounded, l10n.onboardingPillar3),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                            child: Icon(Icons.spa_outlined, size: 26, color: cs.primary),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.onboardingTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.onboardingBody,
                            style: TextStyle(color: cs.onSurfaceVariant, height: 1.45),
                          ),
                          const SizedBox(height: 20),
                          for (final (icon, text) in pillars)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(icon, size: 20, color: cs.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: const TextStyle(fontSize: 13.5, height: 1.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('start-onboarding'),
                onPressed: () async {
                  await ref.read(settingsRepositoryProvider).setOnboardingDone();
                  if (context.mounted) context.go('/');
                },
                child: Text(l10n.onboardingStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
