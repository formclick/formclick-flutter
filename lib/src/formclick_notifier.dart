import 'package:flutter/foundation.dart';

import 'api.dart';
import 'types.dart';

/// State notifier for a single Formclick submission flow.
///
/// This is the Dart equivalent of the `useFormclick` hook in `@formclick/react`.
/// Use it with [ListenableBuilder], [AnimatedBuilder], or any state-management
/// solution that supports [ChangeNotifier] (e.g. `provider`, `riverpod`).
///
/// ### Basic usage with ListenableBuilder
/// ```dart
/// final _notifier = FormclickNotifier();
///
/// ListenableBuilder(
///   listenable: _notifier,
///   builder: (context, _) {
///     if (_notifier.loading) return const CircularProgressIndicator();
///     if (_notifier.success) return const Text('Sent!');
///     if (_notifier.error != null) return Text(_notifier.error.toString());
///     return ElevatedButton(
///       onPressed: _submit,
///       child: const Text('Submit'),
///     );
///   },
/// )
///
/// Future<void> _submit() async {
///   await _notifier.submit(SubmitOptions(
///     formId: 'YOUR_ACCESS_KEY',
///     data: {'name': 'John', 'email': 'john@example.com'},
///   ));
/// }
/// ```
class FormclickNotifier extends ChangeNotifier {
  bool _loading = false;
  Exception? _error;
  bool _success = false;
  SubmitResult? _data;

  /// True while a submission request is in-flight.
  bool get loading => _loading;

  /// The last submission error, or null if the last submission succeeded.
  Exception? get error => _error;

  /// True if the last submission succeeded.
  bool get success => _success;

  /// The last successful server response.
  SubmitResult? get data => _data;

  /// Base URL of the Formclick submissions API.
  final String submitBaseUrl;

  /// Extra headers for every request.
  final Map<String, String>? headers;

  /// Called after every successful submission.
  final void Function(SubmitResult result, SubmitOptions options)? onSuccess;

  /// Called after every submission error.
  final void Function(Exception error, SubmitOptions options)? onError;

  FormclickNotifier({
    this.submitBaseUrl = 'https://api.formclick.io/submit',
    this.headers,
    this.onSuccess,
    this.onError,
  });

  /// Submit form data to Formclick.
  /// Throws an [Exception] on network / server error.
  Future<SubmitResult> submit(SubmitOptions options) async {
    _loading = true;
    _error = null;
    _success = false;
    _data = null;
    notifyListeners();

    try {
      final result = await submitToFormclick(
        options,
        submitBaseUrl: submitBaseUrl,
        headers: headers,
      );

      _loading = false;
      _success = true;
      _data = result;
      notifyListeners();

      onSuccess?.call(result, options);
      return result;
    } on Exception catch (e) {
      _loading = false;
      _error = e;
      _success = false;
      notifyListeners();

      onError?.call(e, options);
      rethrow;
    }
  }

  /// Reset all state back to the initial idle state.
  void reset() {
    _loading = false;
    _error = null;
    _success = false;
    _data = null;
    notifyListeners();
  }
}
