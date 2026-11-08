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
- Headphones and jack microphones reported by PipeWire/PulseAudio through
  `pactl`, using only physically available audio ports and excluding internal
  digital microphones and monitor sources.
- Built-in Bluetooth adapters and controllers are excluded because they are
  system infrastructure, not user-interactable peripherals.
- System-configured printers and devices known to the operating system.
- Device categories based on the actual device instead of the transport
  protocol.
- Connection information such as USB, Bluetooth, network, local, or unknown.
- Network scanning distinguishes printing services from web-only hosts. Hosts
  matching the default gateway or router/access-point fingerprints are shown
  as routers; other responsive hosts are shown as network devices instead of
  being incorrectly labeled as printers. The panel retains the detected
  classification and confidence.
- Operational status: active, inactive, or disconnected.
- Selecting a device opens a responsive details panel. It shows the device
  icon, name, provider when available, ID, type, status, connection, port,
  source details, and other detected attributes. On compact screens it uses
  the full screen; on desktop it appears on the right.
- The details panel includes localized `Info` and `Config` tabs. Configuration
  is intentionally marked as work in progress for now.
- Network discovery can be refreshed independently from the toolbar and
  canceled while running. Existing network devices remain visible during the
  refresh and are replaced only when the new scan completes. Automatic network
  discovery can be enabled in Settings and then runs at startup and every
  minute.
- Physical devices can aggregate multiple detected capabilities into one list
  entry. For example, a headset with audio output and microphone is listed
  once, while both components and their individual data remain visible in the
  `Info` panel.
- Each component in the `Info` panel can be expanded to inspect its technical
  identity, type, status, connection, provider, port, source details, and
  additional attributes. Component IDs are preserved for future configuration
  selection.
- USB printers and plotters can be displayed even when no CUPS driver is
  configured, with their device identity marked as active or unknown.
- Refresh through the toolbar or pull-to-refresh gesture.
- Light and dark themes that follow the operating-system preference.
- Single-instance behavior: launching the application again exits without
  creating a second window or application process.

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
The Linux runner registers a unique application ID so only one instance can
remain active at a time.
