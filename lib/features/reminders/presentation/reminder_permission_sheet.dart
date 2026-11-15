import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

Future<bool> showReminderPermissionSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final res = await showModalBottomSheet<bool>(
    context: context,
    builder: (c) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.permTitle, style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.permBody),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: () => Navigator.pop(c, true), child: Text(l10n.permAllow)),
          TextButton(
              onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
        ],
      ),
    ),
  );
  return res ?? false;
}
