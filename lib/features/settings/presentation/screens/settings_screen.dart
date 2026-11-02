import 'package:flutter/material.dart';

import '../../../../../core/localization/locale_provider.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.localeProvider, this.themeProvider, super.key});

  final LocaleProvider? localeProvider;
  final ThemeProvider? themeProvider;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _colorMode = ThemeMode.system;
  String _interfaceSize = 'normal';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.settings, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _SettingsSection(
          title: l10n.appearance,
          children: [
            _SettingsDropdown<AppThemeStyle>(
              label: l10n.theme,
              value: widget.themeProvider?.themeStyle,
              items: [
                DropdownMenuItem(
                  value: AppThemeStyle.cupertino,
                  child: Text(l10n.themeCupertino),
                ),
                DropdownMenuItem(
                  value: AppThemeStyle.material,
                  child: Text(l10n.themeMaterial),
                ),
                DropdownMenuItem(
                  value: AppThemeStyle.fluent,
                  child: Text(l10n.themeFluent),
                ),
              ],
              enabled: widget.themeProvider != null,
              onChanged: (value) {
                if (value != null) {
                  widget.themeProvider?.setThemeStyle(value);
                }
              },
            ),
            _SettingsDropdown<ThemeMode>(
              label: l10n.colorMode,
              value: _colorMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.light),
                ),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemDefault),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _colorMode = value);
                }
              },
            ),
            _SettingsDropdown<String>(
              label: l10n.interfaceSize,
              value: _interfaceSize,
              items: [
                DropdownMenuItem(
                  value: 'large',
                  child: Text(l10n.interfaceSizeLarge),
                ),
                DropdownMenuItem(
                  value: 'normal',
                  child: Text(l10n.interfaceSizeNormal),
                ),
                DropdownMenuItem(
                  value: 'compact',
                  child: Text(l10n.interfaceSizeCompact),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _interfaceSize = value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: l10n.language,
          children: [
            _SettingsDropdown<Locale>(
              label: l10n.language,
              value: widget.localeProvider?.locale,
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: const Locale('es'),
                  child: Text(l10n.spanish),
                ),
              ],
              enabled: widget.localeProvider != null,
              onChanged: (locale) {
                if (locale != null) {
                  widget.localeProvider?.setLocale(locale);
                }
              },
            ),
            if (widget.localeProvider?.hasManualLocale ?? false)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: widget.localeProvider!.useSystemLocale,
                  child: Text(l10n.systemLanguage),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsDropdown<T> extends StatelessWidget {
  const _SettingsDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(labelText: label),
        initialValue: value,
        items: items,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
