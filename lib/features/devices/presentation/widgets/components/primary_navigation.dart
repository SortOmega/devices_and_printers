import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';

class PrimaryNavigation extends StatelessWidget {
  const PrimaryNavigation({
    required this.activePage,
    required this.onPageChanged,
    super.key,
  });

  final String activePage;
  final ValueChanged<String> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SegmentedButton<String>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              segments: [
                ButtonSegment(
                  value: 'devices',
                  label: Text(l10n.viewDevices),
                  icon: const Icon(Icons.devices_other, size: 18),
                ),
                ButtonSegment(
                  value: 'about',
                  label: Text(l10n.about),
                  icon: const Icon(Icons.info_outline, size: 18),
                ),
                ButtonSegment(
                  value: 'settings',
                  label: Text(l10n.settings),
                  icon: const Icon(Icons.settings_outlined, size: 18),
                ),
              ],
              selected: {activePage},
              onSelectionChanged: (selection) {
                onPageChanged(selection.first);
              },
            ),
          ),
        ),
      ),
    );
  }
}
