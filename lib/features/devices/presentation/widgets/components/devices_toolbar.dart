import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class DevicesToolbar extends StatelessWidget {
  const DevicesToolbar({
    required this.sortOption,
    required this.groupOption,
    required this.onSortChanged,
    required this.onGroupChanged,
    required this.onAddDevice,
    required this.onAddPrinter,
    required this.onRefresh,
    super.key,
  });

  final String sortOption;
  final String groupOption;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onGroupChanged;
  final VoidCallback onAddDevice;
  final VoidCallback onAddPrinter;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final geometry =
        theme.extension<AppThemeGeometry>() ??
        const AppThemeGeometry(
          cardRadius: 12,
          controlRadius: 20,
          dialogRadius: 28,
        );
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.sortLabel),
            DropdownButton<String>(
              value: sortOption,
              isDense: true,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(geometry.controlRadius),
              dropdownColor: theme.colorScheme.surfaceContainer,
              iconSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              style: theme.textTheme.labelLarge,
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
              items: [
                DropdownMenuItem(value: 'name', child: Text(l10n.sortName)),
                DropdownMenuItem(value: 'status', child: Text(l10n.sortStatus)),
                DropdownMenuItem(
                  value: 'connection',
                  child: Text(l10n.sortConnection),
                ),
              ],
            ),
            Text(l10n.groupLabel),
            DropdownButton<String>(
              value: groupOption,
              isDense: true,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(geometry.controlRadius),
              dropdownColor: theme.colorScheme.surfaceContainer,
              iconSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              style: theme.textTheme.labelLarge,
              onChanged: (value) {
                if (value != null) onGroupChanged(value);
              },
              items: [
                DropdownMenuItem(value: 'type', child: Text(l10n.groupType)),
                DropdownMenuItem(
                  value: 'status',
                  child: Text(l10n.groupStatus),
                ),
                DropdownMenuItem(
                  value: 'connection',
                  child: Text(l10n.groupConnection),
                ),
                DropdownMenuItem(
                  value: 'default',
                  child: Text(l10n.groupDefault),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: onAddDevice,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addDevice),
            ),
            OutlinedButton.icon(
              onPressed: onAddPrinter,
              icon: const Icon(Icons.print, size: 18),
              label: Text(l10n.addPrinter),
            ),
            IconButton(
              onPressed: onRefresh,
              tooltip: l10n.refreshDevices,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
