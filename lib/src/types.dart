/// Arbitrary form field values.
/// Supports String, int, double, bool, null, and List<String>.
typedef FormValues = Map<String, dynamic>;

/// Options for a single [submitToFormclick] call.
class SubmitOptions {
  /// Formclick access_key from your dashboard.
  final String formId;

  /// The form field data to submit.
  final FormValues data;

  /// Override the submission endpoint.
  /// Defaults to `https://api.formclick.io/submit/{formId}`.
  final String? submitUrl;

  const SubmitOptions({
    required this.formId,
    required this.data,
    this.submitUrl,
  });
}

/// Result returned from [submitToFormclick].
class SubmitResult {
  final bool success;

  /// Message returned by the server.
  final String? message;

  const SubmitResult({required this.success, this.message});

  factory SubmitResult.fromJson(Map<String, dynamic> json) {
    return SubmitResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Global configuration shared via [FormclickProvider] or passed directly
/// to [FormclickNotifier].
class FormclickConfig {
  /// Base URL of the Formclick submissions API.
  /// Defaults to `https://api.formclick.io/submit`.
  final String submitBaseUrl;

  /// Extra headers attached to every submission request.
  final Map<String, String>? headers;

  /// Called globally after every successful submission.
  final void Function(SubmitResult result, SubmitOptions options)? onSuccess;

  /// Called globally after every submission error.
  final void Function(Exception error, SubmitOptions options)? onError;

  const FormclickConfig({
    this.submitBaseUrl = 'https://api.formclick.io/submit',
    this.headers,
    this.onSuccess,
    this.onError,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormclickConfig &&
          runtimeType == other.runtimeType &&
          submitBaseUrl == other.submitBaseUrl &&
          headers == other.headers;

  @override
  int get hashCode => Object.hash(submitBaseUrl, headers);
}
