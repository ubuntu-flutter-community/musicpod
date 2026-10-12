// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_message_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerMessage)
final playerMessageProvider = PlayerMessageProvider._();

final class PlayerMessageProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  PlayerMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerMessageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerMessageHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return playerMessage(ref);
  }
}

String _$playerMessageHash() => r'ba37a8b7f00b00fac528c10ac8525b1d89d500d2';
