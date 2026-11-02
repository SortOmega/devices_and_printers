import 'package:flutter/material.dart';

import '../../../domain/models/device.dart';
import 'device_card.dart';

class DeviceGroup extends StatelessWidget {
  const DeviceGroup({
    required this.title,
    required this.devices,
    required this.selectedDeviceIds,
    required this.onDeviceSelected,
    super.key,
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
                DeviceCard(
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
