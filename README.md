# formclick

A Flutter/Dart SDK for submitting form data to [Formclick](https://formclick.io).

Mirrors the API design of `@formclick/react` and `@formclick/react-native` — but written in idiomatic Dart using `ChangeNotifier` and `InheritedWidget`.

---

## Platform Support

| Android | iOS | Linux | macOS | Web | Windows |
|:-------:|:---:|:-----:|:-----:|:---:|:-------:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

This is a pure Flutter/Dart package — no native plugin code. It relies on Flutter widgets and the [`http`](https://pub.dev/packages/http) package, which supports all six Flutter platforms.

---

## Prerequisites — Install the Flutter & Dart SDK

Dart ships bundled with Flutter. Installing Flutter gives you both.

### Windows

1. Download the latest Flutter SDK from [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2. Extract to a path **without spaces or special characters**, e.g. `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your `PATH` environment variable
4. Open a new terminal and verify:
   ```powershell
   dart --version
   flutter --version
   flutter doctor
   ```

### macOS

```sh
brew install --cask flutter
dart --version && flutter --version && flutter doctor
```

### Linux

```sh
sudo snap install flutter --classic
dart --version && flutter --version && flutter doctor
```

### Required versions

| SDK | Minimum |
|-----|---------|
| Dart | 3.0.0 |
| Flutter | 3.10.0 |

---

- `FormclickNotifier` — `ChangeNotifier`-based state holder (loading / success / error / data)
- `FormclickProvider` — `InheritedWidget` for app-wide config (base URL, headers, global callbacks)
- `submitToFormclick` — low-level async function for one-shot submissions
- Zero Flutter-specific dependencies beyond `http`
- Works with any state-management solution that supports `ChangeNotifier` (`provider`, `riverpod`, vanilla `ListenableBuilder`)

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  formclick: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## Setup

### Option A — App-wide provider (recommended)

Wrap your root widget with `FormclickProvider` so every `FormclickNotifier` in the tree can read the shared config:

```dart
import 'package:formclick/formclick.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    FormclickProvider(
      config: const FormclickConfig(
        submitBaseUrl: 'https://api.formclick.io/submit',
        // Optional global callbacks
        onSuccess: _onSuccess,
        onError: _onError,
      ),
      child: const MyApp(),
    ),
  );
}

void _onSuccess(SubmitResult result, SubmitOptions options) {
  debugPrint('Submitted! ${result.message}');
}

void _onError(Exception error, SubmitOptions options) {
  debugPrint('Error: $error');
}
```

### Option B — Standalone notifier (no provider needed)

```dart
final _notifier = FormclickNotifier(
  submitBaseUrl: 'https://api.formclick.io/submit',
);
```

---

## Usage

### With `ListenableBuilder` (recommended — no extra packages)

```dart
import 'package:formclick/formclick.dart';
import 'package:flutter/material.dart';

class LeadForm extends StatefulWidget {
  const LeadForm({super.key});

  @override
  State<LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends State<LeadForm> {
  final _formKey = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _email   = TextEditingController();

  late final FormclickNotifier _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read config from the nearest FormclickProvider
    final config = FormclickProvider.of(context);
    _notifier = FormclickNotifier(
      submitBaseUrl: config.submitBaseUrl,
      headers:       config.headers,
      onSuccess:     config.onSuccess,
      onError:       config.onError,
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _notifier.submit(SubmitOptions(
      formId: 'YOUR_ACCESS_KEY',
      data: {
        'name':  _name.text.trim(),
        'email': _email.text.trim(),
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (_notifier.success)
                const Text('Sent! ✓', style: TextStyle(color: Colors.green)),
              if (_notifier.error != null)
                Text(
                  _notifier.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _notifier.loading ? null : _submit,
                child: _notifier.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Message'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### With `provider` package

```dart
// In your widget tree
ChangeNotifierProvider(
  create: (_) => FormclickNotifier(
    submitBaseUrl: 'https://api.formclick.io/submit',
  ),
  child: const LeadForm(),
)

// Inside LeadForm
final notifier = context.watch<FormclickNotifier>();
```

### With `riverpod`

```dart
final formclickProvider = ChangeNotifierProvider<FormclickNotifier>(
  (ref) => FormclickNotifier(
    submitBaseUrl: 'https://api.formclick.io/submit',
  ),
);

// Inside a ConsumerWidget
final notifier = ref.watch(formclickProvider);
```

### Low-level one-shot call

```dart
import 'package:formclick/formclick.dart';

final result = await submitToFormclick(
  SubmitOptions(
    formId: 'YOUR_ACCESS_KEY',
    data: {'name': 'John', 'email': 'john@example.com'},
  ),
);

print(result.success);  // true
print(result.message);  // "Email sent successfully."
```

---

## API Reference

### `FormclickConfig`

| Property | Type | Default | Description |
|---|---|---|---|
| `submitBaseUrl` | `String` | `https://api.formclick.io/submit` | Base URL of the submissions API |
| `headers` | `Map<String,String>?` | `null` | Extra headers for every request |
| `onSuccess` | `void Function(SubmitResult, SubmitOptions)?` | `null` | Global success callback |
| `onError` | `void Function(Exception, SubmitOptions)?` | `null` | Global error callback |

### `FormclickNotifier` (ChangeNotifier)

| Member | Type | Description |
|---|---|---|
| `loading` | `bool` | `true` while a request is in-flight |
| `success` | `bool` | `true` after a successful submission |
| `error` | `Exception?` | Last error, or `null` |
| `data` | `SubmitResult?` | Last successful server response |
| `submit(options)` | `Future<SubmitResult>` | Send a form submission |
| `reset()` | `void` | Reset all state to idle |

### `SubmitOptions`

| Property | Type | Description |
|---|---|---|
| `formId` | `String` | Formclick access_key |
| `data` | `FormValues` (`Map<String, dynamic>`) | Field data to submit |
| `submitUrl` | `String?` | Override the full endpoint URL |

### `SubmitResult`

| Property | Type | Description |
|---|---|---|
| `success` | `bool` | Whether the submission succeeded |
| `message` | `String?` | Server message |

---

## Publishing to pub.dev

### 1. Verify the package

```sh
# Static analysis
flutter analyze

# Dry-run publish (validates package without uploading)
flutter pub publish --dry-run
```

### 2. Score check

Run `pana` locally to preview your pub.dev score:

```sh
dart pub global activate pana
pana .
```

Common score requirements:
- `pubspec.yaml` must have `description`, `homepage`, `repository`
- `README.md`, `CHANGELOG.md`, and `LICENSE` must exist
- All public APIs must have dartdoc comments
- `flutter analyze` must pass with zero issues

### 3. Add a LICENSE file

```sh
# Example: MIT license
curl -o LICENSE https://opensource.org/licenses/MIT
```

### 4. Publish

```sh
flutter pub publish
```

You will be prompted to authenticate with your Google account. The package is uploaded to [pub.dev](https://pub.dev) and is publicly available within a few minutes.

### 5. Updating the package

1. Bump the version in `pubspec.yaml` (follows semver)
2. Add an entry to `CHANGELOG.md`
3. Run `flutter pub publish`

---

## License

MIT © Formclick
