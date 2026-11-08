import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';

class AsyncOperationFooter extends StatelessWidget {
  const AsyncOperationFooter({
    required this.isRunning,
    this.errorMessage,
    super.key,
  });

  final bool isRunning;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (!isRunning && errorMessage == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasError = errorMessage != null;
    return Material(
      color: hasError
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (isRunning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: theme.colorScheme.onErrorContainer,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasError
                      ? l10n.networkScanFailed(errorMessage!)
                      : l10n.networkScanInProgress,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (isRunning)
                Icon(Icons.lan, size: 20, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
