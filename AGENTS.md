# Project Development Guidelines

These instructions apply to all work in this repository. Read the referenced
documents before changing architecture, localization, or tests:

- [Architecture](docs/ARCHITECTURE.md)
- [Internationalization](docs/I18N.md)
- [Testing](docs/TESTS.md)

## Project Scope

This is a Flutter application with a Linux runner. Preserve platform
integration, including native Linux window decorations managed by the desktop
environment. Do not replace native window-manager behavior with a custom
titlebar unless the change is explicitly requested and documented.

The Linux application is single-instance. When validating changes by running
the application, do not launch a second copy while an existing instance is
active. Restart the existing Flutter/Linux execution after code changes; if the
running process cannot be reached, stop or close that execution and start it
again before continuing validation. A failed debug connection must not be
treated as proof that the application is not already running.

## Architecture

- Use the MVVM pattern: Model, View, and ViewModel.
- Keep shared, cross-feature code under `lib/core/`.
- Organize feature code by feature and separate data, domain, and presentation
  responsibilities where applicable.
- Follow the directory and dependency rules in
  [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
- Keep UI widgets focused on presentation. Put state transitions and
  presentation logic in ViewModels, and data access behind repositories or
  services.
- Use dependency injection through the project's service-locator or provider
  configuration. Avoid hidden global state and direct construction of
  replaceable dependencies inside ViewModels.

## Naming and Formatting

- Use `camelCase` for variables, parameters, functions, and methods in every
  language used by the project.
- Use `PascalCase` for classes, structs, enums, types, and interfaces.
- Use `UPPER_CASE` for constants.
- Follow the formatter and linter conventions of each language. Dart code must
  remain compatible with the project's configured Flutter/Dart SDK.
- Prefer small, composable units with explicit types and clear error handling.
- Do not add comments that merely restate the code; document non-obvious
  decisions and platform constraints.

## Internationalization

- All user-facing strings must be localized; do not hard-code text in widgets.
- Supported languages are English (`en`) and Spanish (`es`).
- Detect the system locale and use English as the fallback when it is not
  supported.
- Users must be able to change the language from Settings.
- Persist a manual language selection across sessions.
- React to system-locale changes at runtime when the user has not selected a
  manual override.
- Follow the source-of-truth and provider rules in
  [docs/I18N.md](docs/I18N.md).

## Testing

- Every new feature, function, class, and public method must have corresponding
  tests.
- Mirror the relevant `lib/` structure under `test/`.
- Use fakes and test utilities instead of production services in unit tests.
- Test successful behavior, invalid input, failures, and meaningful boundary
  cases.
- Follow the test layout and validation commands in
  [docs/TESTS.md](docs/TESTS.md).
- Run focused tests for the changed area, then run the full test suite when
  practical. Do not consider an implementation complete when its tests are
  missing or failing.

## Change Discipline

- Inspect existing patterns before introducing a new abstraction.
- Keep changes surgical and preserve existing behavior unless the requirement
  explicitly changes it.
- Update the relevant documentation when architecture, localization, testing,
  or platform behavior changes.
- Do not introduce dependencies when an existing Flutter or project utility
  solves the problem.
- Before finishing, format changed Dart files and verify static analysis and
  tests.

## Device Details Panel

Selecting a device must open the responsive details panel implemented in
`lib/features/devices/presentation/widgets/components/device_details_panel.dart`.
Keep common typed attributes on the `Device` model (`id`, `name`, `vendor`,
`type`, `status`, `connection`, and `connectionPort`) and place uncommon,
source-specific values in `additionalDetails`. The `Info` tab is functional;
the `Config` tab must remain visibly marked as work in progress until settings
integration is implemented. All panel text must use the localized ARB files.
Each `DeviceComponent` must be expandable in the Info tab and expose its
technical fields, including its stable ID, for future component configuration.

Network discovery is an independent operation. The UI must expose a localized
refresh action and a cancel action, preserve previously discovered network
devices while a refresh is running, replace only the network subset when it
finishes, and cancel/invalidate it before a general device load. Automatic
discovery is persisted in the network settings provider and, when enabled,
runs at startup and once per minute.

The devices contextual header must remain usable on mobile widths. Use a
responsive layout that stacks filters and keeps action controls accessible;
never allow the toolbar or primary navigation to overflow horizontally.

Network discovery must not classify a host as a printer solely because it has
HTTP/HTTPS open. Require an actual printing service (`631`, `9100`, or `515`)
for printer classification; classify the default gateway and strong router
hostname signals as routers, and preserve lower-confidence hosts as network
devices with evidence in `additionalDetails`.

Physical devices with multiple system capabilities must be represented as one
list entry using `Device.components`. Keep each component's type, status,
connection, port, and source details in its `DeviceComponent` record so the
Info panel can show the complete physical device without duplicating it in the
list.
