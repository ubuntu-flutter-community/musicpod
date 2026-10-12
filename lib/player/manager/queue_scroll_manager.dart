import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_scroll_manager.g.dart';

class QueueScrollState {
  const QueueScrollState({
    this.autoScroll = true,
    this.isJumping = false,
    this.showSpinner = false,
  });

  final bool autoScroll;
  final bool isJumping;
  final bool showSpinner;

  QueueScrollState copyWith({
    bool? autoScroll,
    bool? isJumping,
    bool? showSpinner,
  }) {
    return QueueScrollState(
      autoScroll: autoScroll ?? this.autoScroll,
      isJumping: isJumping ?? this.isJumping,
      showSpinner: showSpinner ?? this.showSpinner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueScrollState &&
          autoScroll == other.autoScroll &&
          isJumping == other.isJumping &&
          showSpinner == other.showSpinner;

  @override
  int get hashCode => Object.hash(autoScroll, isJumping, showSpinner);
}

@Riverpod(keepAlive: true)
class QueueScrollManager extends _$QueueScrollManager {
  @override
  QueueScrollState build() {
    return const QueueScrollState();
  }

  void toggleAutoScroll() {
    state = state.copyWith(autoScroll: !state.autoScroll);
  }

  void setJumping(bool value) {
    if (state.isJumping == value) return;
    state = state.copyWith(isJumping: value);
  }

  void setShowSpinner(bool value) {
    if (state.showSpinner == value) return;
    state = state.copyWith(showSpinner: value);
  }
}
