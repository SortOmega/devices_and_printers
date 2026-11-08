import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/device.dart';
import 'device_labels.dart';

class DeviceDetailsPanel extends StatelessWidget {
  const DeviceDetailsPanel({
    required this.device,
    required this.onClose,
    super.key,
  });

  final Device device;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          iconForDevice(device),
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          device.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (device.vendor case final vendor?)
                          Text(
                            vendor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: onClose,
                      tooltip: l10n.close,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: l10n.deviceInfoTab),
                Tab(text: l10n.deviceConfigTab),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _InfoTab(device: device),
                  Center(
                    child: Text(
                      l10n.workInProgress,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = <Widget>[
      _DetailRow(label: l10n.deviceId, value: device.id),
      _DetailRow(
        label: l10n.deviceType,
        value: labelForType(device.type, l10n),
      ),
      _DetailRow(
        label: l10n.deviceStatus,
        value: statusLabel(device.status, l10n),
      ),
      _DetailRow(
        label: l10n.deviceConnection,
        value: connectionLabel(device.connection, l10n),
      ),
      if (device.connectionPort != null)
        _DetailRow(label: l10n.devicePort, value: device.connectionPort!),
      if (device.details != null)
        _DetailRow(label: l10n.deviceDetails, value: device.details!),
      for (final entry in device.additionalDetails.entries)
        _DetailRow(label: entry.key, value: entry.value),
    ];
    if (device.components.isNotEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Text(
            l10n.deviceComponents,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      rows.addAll(
        device.components.map(
          (component) => _ComponentCard(component: component),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(20), children: rows);
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.component});

  final DeviceComponent component;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = <String>[
      labelForType(component.type, l10n),
      statusLabel(component.status, l10n),
      if (component.connectionPort != null) component.connectionPort!,
    ];
    final technicalRows = <Widget>[
      _DetailRow(label: l10n.deviceId, value: component.id),
      _DetailRow(
        label: l10n.deviceType,
        value: labelForType(component.type, l10n),
      ),
      _DetailRow(
        label: l10n.deviceStatus,
        value: statusLabel(component.status, l10n),
      ),
      _DetailRow(
        label: l10n.deviceConnection,
        value: connectionLabel(component.connection, l10n),
      ),
      if (component.vendor != null)
        _DetailRow(label: l10n.deviceVendor, value: component.vendor!),
      if (component.connectionPort != null)
        _DetailRow(label: l10n.devicePort, value: component.connectionPort!),
      if (component.details != null)
        _DetailRow(label: l10n.deviceDetails, value: component.details!),
      for (final entry in component.additionalDetails.entries)
        _DetailRow(label: entry.key, value: entry.value),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        key: ValueKey('component:${component.id}'),
        leading: Icon(
          iconForDevice(
            Device(
              id: component.id,
              name: component.name,
              type: component.type,
              connection: component.connection,
              status: component.status,
            ),
          ),
        ),
        title: Text(component.name),
        subtitle: Text(details.join(' · ')),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(children: technicalRows),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          SelectableText(value),
        ],
      ),
    );
  }
}
