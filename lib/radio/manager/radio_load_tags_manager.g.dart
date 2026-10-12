// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_load_tags_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RadioLoadTagsManager)
final radioLoadTagsManagerProvider = RadioLoadTagsManagerProvider._();

final class RadioLoadTagsManagerProvider
    extends $AsyncNotifierProvider<RadioLoadTagsManager, List<Tag>> {
  RadioLoadTagsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radioLoadTagsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radioLoadTagsManagerHash();

  @$internal
  @override
  RadioLoadTagsManager create() => RadioLoadTagsManager();
}

String _$radioLoadTagsManagerHash() =>
    r'76116c48d7098bfbc604fa1f7ec9693849a820ed';

abstract class _$RadioLoadTagsManager extends $AsyncNotifier<List<Tag>> {
  FutureOr<List<Tag>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Tag>>, List<Tag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Tag>>, List<Tag>>,
              AsyncValue<List<Tag>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
