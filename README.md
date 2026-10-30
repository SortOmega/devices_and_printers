# Devices and Printers

Devices and Printers is a Flutter desktop application for Linux that
centralizes the discovery and management of interactive peripherals connected
to a computer. It is inspired by the Windows Control Panel experience and aims
to make devices and printers easy to find, classify, inspect, and configure
from one place.

## Current Features

The first implementation queries the Linux system and displays:

- CUPS printers reported by `lpstat`.
- USB-connected devices reported by `lsusb`, classified as monitors,
  keyboards, mice, headsets, phones, cameras, storage, printers, plotters, or
  unknown devices. Generic and unsupported entries remain visible as unknown
  devices instead of disappearing.
- Known Bluetooth devices reported by `bluetoothctl`, including devices that
  are currently disconnected.
- Built-in Bluetooth adapters and controllers are excluded because they are
  system infrastructure, not user-interactable peripherals.
- System-configured printers and devices known to the operating system.
- Device categories based on the actual device instead of the transport
  protocol.
- Connection information such as USB, Bluetooth, network, local, or unknown.
- Operational status: active, inactive, or disconnected.
- USB printers and plotters can be displayed even when no CUPS driver is
  configured, with their device identity marked as active or unknown.
- Refresh through the toolbar or pull-to-refresh gesture.
- Light and dark themes that follow the operating-system preference.

The Linux commands are treated as system integrations. If an optional command
is unavailable, the application continues displaying devices returned by the
other available integrations.

## Project Direction

Planned capabilities include adding devices and printers, editing device
settings, opening system configuration tools, managing printer queues,
tracking availability, and distinguishing recognized devices from devices
added by the user.

The project follows MVVM and feature-oriented architecture. See:

- [Architecture](docs/ARCHITECTURE.md)
- [Internationalization](docs/I18N.md)
- [Testing](docs/TESTS.md)

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter build linux
```

The application requires a Linux desktop environment and uses the native
window-manager decorations provided by GTK and the desktop environment.
