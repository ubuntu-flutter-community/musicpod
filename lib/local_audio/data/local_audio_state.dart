class LocalAudioState {
  const LocalAudioState({this.failedImports});

  final List<String>? failedImports;

  LocalAudioState copyWith({List<String>? failedImports}) =>
      LocalAudioState(failedImports: failedImports ?? this.failedImports);
}
