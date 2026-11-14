/// Formclick Flutter SDK
///
/// Flutter/Dart client for submitting form data to Formclick.
///
/// ## Quick start
/// ```dart
/// import 'package:formclick/formclick.dart';
///
/// // Wrap your app
/// FormclickProvider(
///   config: const FormclickConfig(
///     submitBaseUrl: 'https://api.formclick.io/submit',
///   ),
///   child: MyApp(),
/// )
///
/// // Inside a widget — create a notifier and listen to state
/// final _notifier = FormclickNotifier();
/// await _notifier.submit(SubmitOptions(
///   formId: 'YOUR_ACCESS_KEY',
///   data: {'name': 'John', 'email': 'john@example.com'},
/// ));
/// ```
library formclick;

export 'src/api.dart' show submitToFormclick;
export 'src/formclick_notifier.dart' show FormclickNotifier;
export 'src/formclick_provider.dart' show FormclickProvider;
export 'src/types.dart'
    show FormValues, FormclickConfig, SubmitOptions, SubmitResult;
