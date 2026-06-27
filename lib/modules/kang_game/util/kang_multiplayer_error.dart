import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'kang_multiplayer_error_stub.dart'
    if (dart.library.html) 'kang_multiplayer_error_web.dart';

void debugKangMultiplayerError(
  String label,
  Object error,
  StackTrace stackTrace,
) {
  final boxedError = kangWebBoxedError(error);
  final effectiveError = boxedError.error ?? error;

  debugPrint('$label failed: $effectiveError');
  if (boxedError.stack != null) {
    debugPrint('Web boxed stack: ${boxedError.stack}');
  }
  debugPrintStack(stackTrace: stackTrace);
}

String kangMultiplayerErrorMessage(Object error) {
  final effectiveError = kangWebBoxedError(error).error ?? error;
  if (effectiveError is FirebaseException) {
    return switch (effectiveError.code) {
      'unavailable' || 'deadline-exceeded' || 'network-request-failed' =>
        'Could not update match. Check your internet connection and try again.',
      'permission-denied' =>
        'Could not update match. Firestore rules may need to be deployed.',
      _ =>
        'Could not update match: ${effectiveError.message ?? effectiveError.code}',
    };
  }

  final message = effectiveError.toString();
  final lowerMessage = message.toLowerCase();
  if (lowerMessage.contains('permission-denied') ||
      lowerMessage.contains('permission denied')) {
    return 'Could not update match. Firestore rules may need to be deployed.';
  }
  if (lowerMessage.contains('unavailable') ||
      lowerMessage.contains('deadline-exceeded') ||
      lowerMessage.contains('network-request-failed') ||
      lowerMessage.contains('failed to fetch') ||
      lowerMessage.contains('client is offline')) {
    return 'Could not update match. Check your internet connection and try again.';
  }
  if (lowerMessage.contains('not-found') ||
      lowerMessage.contains('match no longer exists')) {
    return 'This match is no longer available.';
  }
  if (message.contains('converted Future')) {
    return 'Online action failed on web. Check internet/Firebase setup, then try again.';
  }
  return message;
}
