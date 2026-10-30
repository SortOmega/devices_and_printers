# Architecture

## Overview

The application uses **MVVM (Model-View-ViewModel)** with feature-oriented
organization. The architecture separates presentation, application state,
business/data access, and reusable platform-independent services. New code
must preserve these boundaries.

## Layer Responsibilities

### Model

Models represent application data and domain concepts. They must not depend on
Flutter widgets or presentation concerns. Models should provide explicit,
typed data structures and serialization behavior where needed.

### View

Views are Flutter widgets and screens. They render state, forward user actions,
and display localized content and failures. Views must not contain repository
calls, persistence logic, or complex business rules.

### ViewModel

ViewModels own presentation state and coordinate user actions. They call
repositories and services through injected abstractions, expose loading,
success, and failure states, and notify the View when state changes. They must
be straightforward to unit test without rendering widgets.

### Data and Repositories

Data sources handle external systems such as HTTP, local storage, and platform
APIs. Repositories provide the boundary consumed by ViewModels and map
data-source errors to domain failures. Do not expose HTTP clients or storage
details directly to Views.

## Required Shared Structure

Shared code belongs under `lib/core/`:

```text
core/
├── constants/
│   ├── app_constants.dart      # Application name, version, and paths
│   └── storage_constants.dart  # Shared-preferences and storage keys
├── errors/
│   ├── exceptions.dart         # Custom exceptions
│   └── failures.dart           # Failures mapped to the UI
├── network/
│   ├── api_client.dart         # Base HTTP client (Dio, http, or equivalent)
│   └── interceptors/
│       └── auth_interceptor.dart
├── theme/
│   ├── app_theme.dart          # Global ThemeData
│   ├── colors.dart
│   └── text_styles.dart
├── utils/
│   ├── validators.dart
│   └── extensions.dart
└── di/
    └── service_locator.dart    # get_it or Riverpod overrides
```

Only add a shared utility when it is genuinely cross-feature. Feature-specific
code belongs inside its feature directory.

The global theme must use `ThemeMode.system` so the application follows the
operating system's light or dark preference. Keep shared colors, typography,
hover states, focus states, and surface defaults in `ThemeData`; do not set
widget colors directly unless that element intentionally requires a specific
visual treatment. An explicit widget style always takes precedence over the
inherited theme.

Device discovery must represent user-relevant devices rather than exposing
every low-level USB entry. USB is a transport detail; classify meaningful devices such as monitors,
keyboards, mice, headsets, phones, cameras, storage devices, printers, and
plotters by their system identity. Records that cannot be classified must
remain visible as `unknown` rather than being silently dropped, so a connected
device without a driver can still be identified and added later. USB hubs,
root hubs, and host-controller entries are transport infrastructure rather
than connected peripherals and must be excluded. Built-in Bluetooth adapters,
radios, and controllers, such as Intel AX201 Bluetooth, are also system
infrastructure and must be excluded. Only remote Bluetooth peripherals belong
in the device list. System-known printers and Bluetooth devices may remain
visible when disconnected so users can distinguish saved devices from active
devices.

## Feature Structure

Use a structure like this for feature work:

```text
features/
└── <feature_name>/
    ├── data/
    │   ├── data_sources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── use_cases/
    └── presentation/
        ├── screens/
        ├── widgets/
        └── view_models/
```

Not every feature requires every directory. Keep the structure proportional to
the feature, but do not collapse unrelated responsibilities into one file.

## Dependency Direction

Dependencies should point inward:

```text
View -> ViewModel -> Domain repository abstraction
                         ^
Data repository implementation -> data sources
```

Presentation code may depend on domain abstractions and shared core services.
Data implementations may depend on domain contracts. Domain code must not
depend on Flutter widgets, concrete HTTP clients, or storage implementations.

## Dependency Injection

Register long-lived services and replaceable dependencies in
`lib/core/di/service_locator.dart` or the selected Riverpod provider
configuration. Constructor-inject dependencies into ViewModels, repositories,
and services. Tests must be able to substitute fakes without relying on a
global production registration.

## Linux Platform Integration

The Linux runner is responsible for platform-specific window setup. The
application must allow GTK and the desktop environment to provide native
window decorations for GNOME, KDE Plasma, and other Linux environments. Keep
platform code isolated under `linux/runner/` and avoid leaking GTK-specific
types into Dart application layers.
