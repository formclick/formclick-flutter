import 'package:flutter/widgets.dart';

import 'types.dart';

/// [InheritedWidget] that provides a [FormclickConfig] to its subtree.
///
/// Wrap your app (or any subtree) with [FormclickProvider] to share a global
/// Formclick configuration. Any [FormclickNotifier] created inside the subtree
/// can read this config via [FormclickProvider.of].
///
/// ### Usage
/// ```dart
/// FormclickProvider(
///   config: const FormclickConfig(
///     submitBaseUrl: 'https://api.formclick.io/submit',
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// ### Reading the config
/// ```dart
/// final config = FormclickProvider.of(context);
/// final notifier = FormclickNotifier(
///   submitBaseUrl: config.submitBaseUrl,
///   headers: config.headers,
///   onSuccess: config.onSuccess,
///   onError: config.onError,
/// );
/// ```
class FormclickProvider extends InheritedWidget {
  /// The configuration to provide to the subtree.
  final FormclickConfig config;

  const FormclickProvider({
    super.key,
    required this.config,
    required super.child,
  });

  /// Returns the nearest [FormclickConfig] in the widget tree.
  /// Falls back to a default config if no provider is found.
  static FormclickConfig of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<FormclickProvider>();
    return provider?.config ?? const FormclickConfig();
  }

  @override
  bool updateShouldNotify(FormclickProvider oldWidget) {
    return config != oldWidget.config;
  }
}
