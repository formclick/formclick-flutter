import 'dart:convert';

import 'package:http/http.dart' as http;

import 'types.dart';

const _defaultBase = 'https://api.formclick.io/submit';

/// Low-level HTTP wrapper.
/// Serialises [FormValues] to JSON and POSTs to the Formclick submissions API.
///
/// Throws an [Exception] on non-2xx responses.
Future<SubmitResult> submitToFormclick(
  SubmitOptions options, {
  String? submitBaseUrl,
  Map<String, String>? headers,
}) async {
  final base = submitBaseUrl ?? _defaultBase;
  final uri = options.submitUrl != null
      ? Uri.parse(options.submitUrl!)
      : Uri.parse('$base/${Uri.encodeComponent(options.formId)}');

  final payload = _sanitiseValues(options.data, options.formId);

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    },
    body: jsonEncode(payload),
  );

  Map<String, dynamic> body;
  try {
    body = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (_) {
    body = {};
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final msg = body['error'] as String? ??
        'Request failed with status ${response.statusCode}';
    throw Exception('[Formclick] $msg');
  }

  return SubmitResult.fromJson(body);
}

/// Serialise form values to a JSON-safe map, injecting [accessKey].
Map<String, dynamic> _sanitiseValues(FormValues values, String accessKey) {
  final out = <String, dynamic>{'access_key': accessKey};

  for (final entry in values.entries) {
    final val = entry.value;
    if (val == null) {
      out[entry.key] = null;
    } else if (val is String || val is num || val is bool || val is List) {
      out[entry.key] = val;
    } else {
      // Coerce anything else to string
      out[entry.key] = val.toString();
    }
  }

  return out;
}
