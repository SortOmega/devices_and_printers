import 'package:flutter/material.dart';

import '../../domain/models/device.dart';
import '../view_models/device_list_view_model.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({required this.viewModel, super.key});

  final DeviceListViewModel viewModel;

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  // Keep the set-based representation so multi-selection can be enabled later.
  final Set<String> _selectedDeviceIds = <String>{};
  static const bool _allowMultipleSelection = false;
  String _activePage = 'devices';
  String _sortOption = 'name';
  String _groupOption = 'type';

  void _toggleSelection(String deviceId) {
    setState(() {
      if (_selectedDeviceIds.contains(deviceId)) {
        _selectedDeviceIds.remove(deviceId);
      } else {
        if (!_allowMultipleSelection) {
          _selectedDeviceIds.clear();
        }
        _selectedDeviceIds.add(deviceId);
      }
    });
  }

  List<MapEntry<String, List<Device>>> _deviceGroups() {
    final devices = [...widget.viewModel.devices]
      ..sort((first, second) {
        return switch (_sortOption) {
          'status' => statusLabel(
            first.status,
          ).compareTo(statusLabel(second.status)),
          'connection' => connectionLabel(
            first.connection,
          ).compareTo(connectionLabel(second.connection)),
          _ => first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        };
      });
    final groups = <String, List<Device>>{};
    for (final device in devices) {
      final key = switch (_groupOption) {
        'status' => statusLabel(device.status),
        'connection' => connectionLabel(device.connection),
        _ => _labelForType(device.type),
      };
      groups.putIfAbsent(key, () => []).add(device);
    }
    return groups.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildPrimaryHeader(context),
              if (_activePage == 'devices') _buildDevicesHeader(context),
              Expanded(
                child: _activePage == 'devices'
                    ? _buildBody(context)
                    : const _AboutPage(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrimaryHeader(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SegmentedButton<String>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: 'devices',
                  label: Text('View Devices'),
                  icon: Icon(Icons.devices_other, size: 18),
                ),
                ButtonSegment(
                  value: 'about',
                  label: Text('About'),
                  icon: Icon(Icons.info_outline, size: 18),
                ),
              ],
              selected: {_activePage},
              onSelectionChanged: (selection) {
                setState(() => _activePage = selection.first);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevicesHeader(BuildContext context) {
    return Material(
      // color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: _sortOption,
              isDense: true,
              underline: const SizedBox.shrink(),
              iconSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              style: Theme.of(context).textTheme.labelLarge,
              onChanged: (value) {
                if (value != null) setState(() => _sortOption = value);
              },
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                DropdownMenuItem(value: 'status', child: Text('Sort: Status')),
                DropdownMenuItem(
                  value: 'connection',
                  child: Text('Sort: Connection'),
                ),
              ],
            ),
            DropdownButton<String>(
              value: _groupOption,
              isDense: true,
              underline: const SizedBox.shrink(),
              iconSize: 18,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              style: Theme.of(context).textTheme.labelLarge,
              onChanged: (value) {
                if (value != null) setState(() => _groupOption = value);
              },
              items: const [
                DropdownMenuItem(value: 'type', child: Text('Group: Type')),
                DropdownMenuItem(value: 'status', child: Text('Group: Status')),
                DropdownMenuItem(
                  value: 'connection',
                  child: Text('Group: Connection'),
                ),
              ],
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.comfortable,
              ),
              onPressed: () => _showAddDialog(context, 'device'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Device'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.comfortable,
              ),
              onPressed: () => _showAddDialog(context, 'printer'),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Add Printer'),
            ),
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: widget.viewModel.loadDevices,
              tooltip: 'Refresh devices',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, String itemType) {
    final title = itemType == 'printer' ? 'Add Printer' : 'Add Device';
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          '$title will be available when system configuration integration '
          'is added.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.viewModel.status == DeviceListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.viewModel.status == DeviceListStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.viewModel.errorMessage ?? 'Unable to load devices'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.viewModel.loadDevices,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (widget.viewModel.devices.isEmpty) {
      return const Center(
        child: Text('No connected devices or printers were found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.loadDevices,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${widget.viewModel.devices.length} known devices',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final entry in _deviceGroups())
            _DeviceGroup(
              title: entry.key,
              devices: entry.value,
              selectedDeviceIds: _selectedDeviceIds,
              onDeviceSelected: _toggleSelection,
            ),
        ],
      ),
    );
  }
}

String _labelForType(DeviceType type) {
  return switch (type) {
    DeviceType.printer => 'Printers',
    DeviceType.plotter => 'Plotters',
    DeviceType.monitor => 'Monitors',
    DeviceType.headset => 'Headsets',
    DeviceType.microphone => 'Microphones',
    DeviceType.mouse => 'Mice',
    DeviceType.keyboard => 'Keyboards',
    DeviceType.phone => 'Phones',
    DeviceType.camera => 'Cameras',
    DeviceType.storage => 'Storage',
    DeviceType.unknown => 'Unknown devices',
    DeviceType.bluetooth => 'Bluetooth devices',
  };
}

class _DeviceGroup extends StatelessWidget {
  const _DeviceGroup({
    required this.title,
    required this.devices,
    required this.selectedDeviceIds,
    required this.onDeviceSelected,
  });

  final String title;
  final List<Device> devices;
  final Set<String> selectedDeviceIds;
  final ValueChanged<String> onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final device in devices)
                _DeviceCard(
                  device: device,
                  isSelected: selectedDeviceIds.contains(device.id),
                  onSelected: onDeviceSelected,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.devices_other,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Devices and Printers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'A centralized Linux view for discovering and managing '
                'connected devices and printers.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatefulWidget {
  const _DeviceCard({
    required this.device,
    required this.isSelected,
    required this.onSelected,
  });

  final Device device;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(widget.device.id),
        child: AnimatedContainer(
          key: ValueKey(widget.device.id),
          duration: const Duration(milliseconds: 150),
          width: 156,
          height: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : _isHovered
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : _isHovered
                  ? theme.colorScheme.outline
                  : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              if (_isHovered && !isSelected)
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                iconForDevice(widget.device),
                size: 52,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
              ),
              Text(
                widget.device.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${statusLabel(widget.device.status)} · '
                '${connectionLabel(widget.device.connection)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData iconForDevice(Device device) {
  return switch (device.type) {
    DeviceType.printer => Icons.print,
    DeviceType.plotter => Icons.print,
    DeviceType.monitor => Icons.monitor,
    DeviceType.headset => Icons.headset,
    DeviceType.microphone => Icons.mic,
    DeviceType.mouse => Icons.mouse,
    DeviceType.keyboard => Icons.keyboard,
    DeviceType.phone => Icons.smartphone,
    DeviceType.camera => Icons.camera_alt,
    DeviceType.storage => Icons.storage,
    DeviceType.unknown => Icons.device_unknown,
    DeviceType.bluetooth => Icons.bluetooth,
  };
}

String connectionLabel(DeviceConnection connection) {
  return switch (connection) {
    DeviceConnection.usb => 'USB',
    DeviceConnection.bluetooth => 'Bluetooth',
    DeviceConnection.audioJack => 'Audio jack',
    DeviceConnection.network => 'Network',
    DeviceConnection.local => 'Local',
    DeviceConnection.unknown => 'Unknown connection',
  };
}

String statusLabel(DeviceStatus status) {
  return switch (status) {
    DeviceStatus.active => 'Active',
    DeviceStatus.inactive => 'Inactive',
    DeviceStatus.disconnected => 'Disconnected',
  };
}
