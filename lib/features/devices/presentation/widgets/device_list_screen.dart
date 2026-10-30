import 'package:flutter/material.dart';

import '../../domain/models/device.dart';
import '../view_models/device_list_view_model.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({required this.viewModel, super.key});

  final DeviceListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Devices and Printers'),
            actions: [
              IconButton(
                onPressed: viewModel.loadDevices,
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
    if (viewModel.status == DeviceListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.status == DeviceListStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.errorMessage ?? 'Unable to load devices'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: viewModel.loadDevices,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (viewModel.devices.isEmpty) {
      return const Center(
        child: Text('No connected devices or printers were found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadDevices,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${viewModel.devices.length} recognized items',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final entry in viewModel.groupedDevices.entries)
            _DeviceGroup(type: entry.key, devices: entry.value),
        ],
      ),
    );
  }
}

class _DeviceGroup extends StatelessWidget {
  const _DeviceGroup({required this.type, required this.devices});

  final DeviceType type;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(_iconFor(type)),
        title: Text(_labelFor(type)),
        subtitle: Text('${devices.length} recognized'),
        children: [
          for (final device in devices)
            ListTile(
              leading: Icon(_iconFor(device.type)),
              title: Text(device.name),
              subtitle: Text(
                '${_connectionLabel(device.connection)} · '
                '${device.status == DeviceStatus.recognized ? 'Recognized' : 'Unavailable'}',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(DeviceType type) {
    return switch (type) {
      DeviceType.printer => Icons.print,
      DeviceType.usb => Icons.usb,
      DeviceType.bluetooth => Icons.bluetooth,
    };
  }

  String _labelFor(DeviceType type) {
    return switch (type) {
      DeviceType.printer => 'Printers',
      DeviceType.usb => 'USB devices',
      DeviceType.bluetooth => 'Bluetooth devices',
    };
  }

  String _connectionLabel(DeviceConnection connection) {
    return switch (connection) {
      DeviceConnection.usb => 'USB',
      DeviceConnection.bluetooth => 'Bluetooth',
      DeviceConnection.network => 'Network',
      DeviceConnection.local => 'Local',
      DeviceConnection.unknown => 'Unknown connection',
    };
  }
}
