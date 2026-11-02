import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../domain/models/device.dart';
import 'device_labels.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    required this.device,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final Device device;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final geometry =
        theme.extension<AppThemeGeometry>() ??
        const AppThemeGeometry(
          cardRadius: 12,
          controlRadius: 20,
          dialogRadius: 28,
        );
    final l10n = AppLocalizations.of(context);
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
            borderRadius: BorderRadius.circular(geometry.cardRadius),
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
                '${statusLabel(widget.device.status, l10n)} · '
                '${connectionLabel(widget.device.connection, l10n)}',
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
