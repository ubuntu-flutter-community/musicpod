class BackupState {
  const BackupState({
    this.localAudio = false,
    this.podcast = false,
    this.radio = false,
  });

  final bool localAudio;
  final bool podcast;
  final bool radio;

  bool get confirmEnabled => localAudio && podcast && radio;

  BackupState copyWith({bool? localAudio, bool? podcast, bool? radio}) {
    return BackupState(
      localAudio: localAudio ?? this.localAudio,
      podcast: podcast ?? this.podcast,
      radio: radio ?? this.radio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupState &&
          runtimeType == other.runtimeType &&
          localAudio == other.localAudio &&
          podcast == other.podcast &&
          radio == other.radio;

  @override
  int get hashCode => Object.hash(localAudio, podcast, radio);
}
