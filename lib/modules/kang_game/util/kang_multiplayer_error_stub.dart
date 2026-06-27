class KangWebBoxedError {
  const KangWebBoxedError({this.error, this.stack});

  final Object? error;
  final Object? stack;
}

KangWebBoxedError kangWebBoxedError(Object error) {
  return const KangWebBoxedError();
}
