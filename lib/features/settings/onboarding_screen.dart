import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../habits/application/providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bolt, size: 72),
              const SizedBox(height: 24),
              Text(l10n.onboardingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(l10n.onboardingBody, textAlign: TextAlign.center),
              const SizedBox(height: 32),
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
