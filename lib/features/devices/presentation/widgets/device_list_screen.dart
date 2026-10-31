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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Devices and Printers'),
            actions: [
              IconButton(
                onPressed: widget.viewModel.loadDevices,
                tooltip: 'Refresh devices',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _buildBody(context),
        );
      },
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
          for (final entry in widget.viewModel.groupedDevices.entries)
            _DeviceGroup(
              type: entry.key,
              devices: entry.value,
              selectedDeviceIds: _selectedDeviceIds,
              onDeviceSelected: _toggleSelection,
            ),
        ],
      ),
    );
  }
}

class _DeviceGroup extends StatelessWidget {
  const _DeviceGroup({
    required this.type,
    required this.devices,
    required this.selectedDeviceIds,
    required this.onDeviceSelected,
  });

  final DeviceType type;
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
            child: Text(
              _labelFor(type),
              style: Theme.of(context).textTheme.titleLarge,
            ),
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

  String _labelFor(DeviceType type) {
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
