// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class KangWebBoxedError {
  const KangWebBoxedError({this.error, this.stack});

  final Object? error;
  final Object? stack;
}

KangWebBoxedError kangWebBoxedError(Object error) {
  Object? boxedError;
  Object? boxedStack;

  try {
    final jsObject = error as JSObject;
    if (jsObject.has('error')) {
      boxedError = jsObject['error']?.dartify();
    }
    if (jsObject.has('stack')) {
      boxedStack = jsObject['stack']?.dartify();
    }
  } catch (_) {
    return const KangWebBoxedError();
  }

  return KangWebBoxedError(error: boxedError, stack: boxedStack);
}
