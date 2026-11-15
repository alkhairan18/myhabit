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
    final habits = ref.watch(archivedHabitsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.archiveTitle)),
      body: habits.isEmpty
          ? Center(child: Text(l10n.noArchived))
          : ListView(children: [
              for (final h in habits)
                ListTile(
                  leading: Icon(iconFor(h.icon), color: Color(h.color)),
                  title: Text(h.name),
                  onTap: () => context.push('/habit/${h.id}'),
                  trailing: IconButton(
                    key: Key('restore-${h.id}'),
                    tooltip: l10n.unarchive,
                    icon: const Icon(Icons.unarchive_outlined),
                    onPressed: () =>
                        ref.read(habitRepositoryProvider).unarchive(h.id),
                  ),
                ),
            ]),
    );
  }
}
