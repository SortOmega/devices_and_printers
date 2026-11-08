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
    required this.onRefreshNetwork,
    required this.isScanningNetwork,
    super.key,
  });

  final String sortOption;
  final String groupOption;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onGroupChanged;
  final VoidCallback onAddDevice;
  final VoidCallback onAddPrinter;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshNetwork;
  final bool isScanningNetwork;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
              vertical: isCompact ? 8 : 6,
            ),
            child: isCompact
                ? _CompactToolbar(
                    sortOption: sortOption,
                    groupOption: groupOption,
                    onSortChanged: onSortChanged,
                    onGroupChanged: onGroupChanged,
                    onAddDevice: onAddDevice,
                    onAddPrinter: onAddPrinter,
                    onRefresh: onRefresh,
                    onRefreshNetwork: onRefreshNetwork,
                    isScanningNetwork: isScanningNetwork,
                    geometry: geometry,
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.sortLabel),
                      DropdownButton<String>(
                        value: sortOption,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        borderRadius: BorderRadius.circular(
                          geometry.controlRadius,
                        ),
                        dropdownColor: theme.colorScheme.surfaceContainer,
                        iconSize: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        style: theme.textTheme.labelLarge,
                        onChanged: (value) {
                          if (value != null) onSortChanged(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text(l10n.sortName),
                          ),
                          DropdownMenuItem(
                            value: 'status',
                            child: Text(l10n.sortStatus),
                          ),
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
                        borderRadius: BorderRadius.circular(
                          geometry.controlRadius,
                        ),
                        dropdownColor: theme.colorScheme.surfaceContainer,
                        iconSize: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        style: theme.textTheme.labelLarge,
                        onChanged: (value) {
                          if (value != null) onGroupChanged(value);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'type',
                            child: Text(l10n.groupType),
                          ),
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
                      IconButton(
                        onPressed: isScanningNetwork ? null : onRefreshNetwork,
                        tooltip: l10n.refreshNetworkDevices,
                        icon: const Icon(Icons.lan),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _CompactToolbar extends StatelessWidget {
  const _CompactToolbar({
    required this.sortOption,
    required this.groupOption,
    required this.onSortChanged,
    required this.onGroupChanged,
    required this.onAddDevice,
    required this.onAddPrinter,
    required this.onRefresh,
    required this.onRefreshNetwork,
    required this.isScanningNetwork,
    required this.geometry,
  });

  final String sortOption;
  final String groupOption;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onGroupChanged;
  final VoidCallback onAddDevice;
  final VoidCallback onAddPrinter;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshNetwork;
  final bool isScanningNetwork;
  final AppThemeGeometry geometry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ToolbarDropdown(
                label: l10n.sortLabel,
                value: sortOption,
                borderRadius: geometry.controlRadius,
                dropdownColor: theme.colorScheme.surfaceContainer,
                items: [
                  DropdownMenuItem(value: 'name', child: Text(l10n.sortName)),
                  DropdownMenuItem(
                    value: 'status',
                    child: Text(l10n.sortStatus),
                  ),
                  DropdownMenuItem(
                    value: 'connection',
                    child: Text(l10n.sortConnection),
                  ),
                ],
                onChanged: onSortChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToolbarDropdown(
                label: l10n.groupLabel,
                value: groupOption,
                borderRadius: geometry.controlRadius,
                dropdownColor: theme.colorScheme.surfaceContainer,
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
                onChanged: onGroupChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAddDevice,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addDevice),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddPrinter,
                icon: const Icon(Icons.print, size: 18),
                label: Text(l10n.addPrinter),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onRefresh,
              tooltip: l10n.refreshDevices,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: isScanningNetwork ? null : onRefreshNetwork,
              tooltip: l10n.refreshNetworkDevices,
              icon: const Icon(Icons.lan),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolbarDropdown extends StatelessWidget {
  const _ToolbarDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.borderRadius,
    required this.dropdownColor,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;
  final double borderRadius;
  final Color dropdownColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isDense: true,
      decoration: InputDecoration(labelText: label),
      borderRadius: BorderRadius.circular(borderRadius),
      dropdownColor: dropdownColor,
      items: items,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
