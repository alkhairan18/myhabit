import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../application/providers.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final habitsAsync = ref.watch(archivedHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.archiveTitle)),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (habits) => habits.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.noArchived,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final h in habits)
                    Card(
                      child: ListTile(
                        leading: Icon(iconFor(h.icon), color: Color(h.color)),
                        title: Text(h.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () => context.push('/habit/${h.id}'),
                        trailing: IconButton(
                          key: Key('restore-${h.id}'),
                          tooltip: l10n.unarchive,
                          icon: const Icon(Icons.unarchive_outlined),
                          onPressed: () async {
                            await ref.read(habitRepositoryProvider).unarchive(h.id);
                            await syncReminders(ref);
                          },
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
