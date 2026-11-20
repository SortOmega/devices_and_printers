import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../l10n/generated/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({this.onOpenUrl, super.key});

  final Future<bool> Function(Uri uri)? onOpenUrl;

  static const _repositoryUri =
      'https://github.com/SortOmega/devices_and_printers';
  static const _licenseUri =
      'https://github.com/SortOmega/devices_and_printers/blob/main/LICENSE';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 16 : 32),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 20 : 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: isCompact ? 56 : 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.aboutDevelopedBy,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.aboutDescription, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _AboutLink(
                        icon: Icons.code,
                        label: l10n.aboutProjectRepository,
                        value: _repositoryUri,
                        actionLabel: l10n.aboutViewRepository,
                        onTap: () => _openUrl(_repositoryUri),
                      ),
                      const SizedBox(height: 12),
                      _AboutLink(
                        icon: Icons.balance,
                        label: l10n.aboutLicense,
                        value: l10n.aboutLicenseGpl2,
                        actionLabel: l10n.aboutViewLicense,
                        onTap: () => _openUrl(_licenseUri),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _openUrl(String url) {
    final opener =
        onOpenUrl ??
        ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));
    return opener(Uri.parse(url));
  }
}

class _AboutLink extends StatelessWidget {
  const _AboutLink({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.actionLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(actionLabel ?? label),
          ),
        ),
      ],
    );
  }
}
