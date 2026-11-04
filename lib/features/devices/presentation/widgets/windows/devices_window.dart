import 'package:flutter/material.dart';

import '../../../../../core/localization/locale_provider.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/device.dart';
import '../../view_models/device_list_view_model.dart';
import 'about_window.dart';
import '../components/device_group.dart';
import '../components/device_labels.dart';
import '../components/devices_toolbar.dart';
import '../components/primary_navigation.dart';
import 'settings_window.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({
    required this.viewModel,
    this.localeProvider,
    this.themeProvider,
    super.key,
  });

  final DeviceListViewModel viewModel;
  final LocaleProvider? localeProvider;
  final ThemeProvider? themeProvider;

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final Set<String> _selectedDeviceIds = <String>{};
  String _activePage = 'devices';
  String _sortOption = 'name';
  String _groupOption = 'default';

  void _toggleSelection(String deviceId) {
    setState(() {
      if (_selectedDeviceIds.contains(deviceId)) {
        _selectedDeviceIds.remove(deviceId);
      } else {
        _selectedDeviceIds
          ..clear()
          ..add(deviceId);
      }
    });
  }

  List<MapEntry<String, List<Device>>> _deviceGroups() {
    final l10n = AppLocalizations.of(context);
    final devices = [...widget.viewModel.devices]
      ..sort((first, second) {
        final unknownOrder = _unknownDeviceOrder(first)
            .compareTo(_unknownDeviceOrder(second));
        if (unknownOrder != 0) {
          return unknownOrder;
        }
        return switch (_sortOption) {
          'status' => statusLabel(
            first.status,
            l10n,
          ).compareTo(statusLabel(second.status, l10n)),
          'connection' => connectionLabel(
            first.connection,
            l10n,
          ).compareTo(connectionLabel(second.connection, l10n)),
          _ => first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        };
      });
    final groups = <String, List<Device>>{};
    for (final device in devices) {
      final key = switch (_groupOption) {
        'status' => statusLabel(device.status, l10n),
        'connection' => connectionLabel(device.connection, l10n),
        'default' => _defaultGroupLabel(device, l10n),
        _ => labelForType(device.type, l10n),
      };
      groups.putIfAbsent(key, () => []).add(device);
    }
    final entries = groups.entries.toList();
    if (_groupOption == 'default') {
      entries.sort(
        (first, second) =>
            _defaultGroupOrder(first.value.first)
                .compareTo(_defaultGroupOrder(second.value.first)),
      );
    } else {
      entries.sort((first, second) {
        final firstUnknown = first.value.any(_isUnknownDevice);
        final secondUnknown = second.value.any(_isUnknownDevice);
        return firstUnknown == secondUnknown
            ? 0
            : firstUnknown
            ? 1
            : -1;
      });
    }
    return entries;
  }

  int _unknownDeviceOrder(Device device) => _isUnknownDevice(device) ? 1 : 0;

  bool _isUnknownDevice(Device device) => device.type == DeviceType.unknown;

  int _defaultGroupOrder(Device device) {
    if (_isUnknownDevice(device)) {
      return 2;
    }
    if (device.isPrinter || device.type == DeviceType.plotter) {
      return 1;
    }
    return 0;
  }

  String _defaultGroupLabel(Device device, AppLocalizations l10n) {
    if (_isUnknownDevice(device)) {
      return l10n.windowsUnknown;
    }
    if (device.isPrinter || device.type == DeviceType.plotter) {
      return l10n.windowsPrinters;
    }
    return l10n.windowsDevices;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            PrimaryNavigation(
              activePage: _activePage,
              onPageChanged: (page) => setState(() => _activePage = page),
            ),
            if (_activePage == 'devices')
              DevicesToolbar(
                sortOption: _sortOption,
                groupOption: _groupOption,
                onSortChanged: (value) => setState(() => _sortOption = value),
                onGroupChanged: (value) => setState(() => _groupOption = value),
                onAddDevice: () => _showAddDialog(context, 'device'),
                onAddPrinter: () => _showAddDialog(context, 'printer'),
                onRefresh: widget.viewModel.loadDevices,
              ),
            Expanded(child: _buildPage(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return switch (_activePage) {
      'devices' => _buildDevicesPage(context),
      'settings' => SettingsScreen(
        localeProvider: widget.localeProvider,
        themeProvider: widget.themeProvider,
      ),
      _ => const AboutPage(),
    };
  }

  Widget _buildDevicesPage(BuildContext context) {
    if (widget.viewModel.status == DeviceListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.viewModel.status == DeviceListStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.viewModel.errorMessage == null
                  ? AppLocalizations.of(context).unableToLoadDevices
                  : AppLocalizations.of(context).unableToQuerySystemDevices(
                      widget.viewModel.errorMessage!,
                    ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.viewModel.loadDevices,
              child: Text(AppLocalizations.of(context).tryAgain),
            ),
          ],
        ),
      );
    }
    if (widget.viewModel.devices.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).noConnectedDevices),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.loadDevices,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)
                .knownDevices(widget.viewModel.devices.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final entry in _deviceGroups())
            DeviceGroup(
              title: entry.key,
              devices: entry.value,
              selectedDeviceIds: _selectedDeviceIds,
              onDeviceSelected: _toggleSelection,
            ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, String itemType) {
    final l10n = AppLocalizations.of(context);
    final title = itemType == 'printer' ? l10n.addPrinter : l10n.addDevice;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(l10n.addItemUnavailable(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
