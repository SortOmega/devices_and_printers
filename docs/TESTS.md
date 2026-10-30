# Testing

## Test-First Expectation

Every new feature, function, class, and public method must include a
corresponding test. Tests are part of the implementation, not a follow-up
task. A change is incomplete if its required tests are absent or failing.

Tests must cover the behavior that users and dependent layers observe,
including successful paths, validation errors, failures, persistence, and
meaningful edge cases.

## Mirrored Test Structure

Tests mirror the relevant structure of `lib/`:

```text
test/
├── l10n/
│   └── app_en.dart
├── core/
│   └── utils/
│       └── validators_test.dart
├── features/
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       └── presentation/
│           └── view_models/
│               └── login_view_model_test.dart
└── test_utils/
    └── fakes/
        └── fake_auth_repository.dart
```

Use descriptive test names that explain the scenario and expected result.
Keep reusable fakes, builders, and fixtures under `test/test_utils/`.
Production network services, platform channels, and persistent stores must not
be used by unit tests unless the test explicitly targets that integration.

## Test Types

### Unit Tests

Use unit tests for validators, models, mappers, repositories, services, and
ViewModels. Inject fakes and verify state transitions, calls, returned values,
and mapped failures.

### Widget Tests

Use widget tests for screen composition, user interaction, loading/error
states, localized labels, and navigation behavior. Keep business logic out of
widget tests when a ViewModel unit test can verify it more directly.

### Integration Tests

Use integration tests for critical flows that cross multiple layers or depend
on real platform behavior. Keep them focused and deterministic.

## Localization Test Coverage

Localization changes must include tests for:

- Supported locale resolution.
- English fallback for unsupported locales.
- Manual language changes from Settings.
- Persistence across provider/application recreation.
- Resetting a manual override to system locale.
- Runtime system-locale changes when no override is active.
- Presence and placeholder consistency of required ARB messages.

## Validation Commands

Run the smallest relevant validation first:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

For a focused change, run the relevant test file, for example:

```bash
flutter test test/core/utils/validators_test.dart
```

If Linux platform code changes, also validate the Linux build when the
environment provides the required Flutter and GTK toolchains:

```bash
flutter build linux
```

Report unavailable tooling or environment failures explicitly; do not replace
failed validation with an unverified claim of success.
