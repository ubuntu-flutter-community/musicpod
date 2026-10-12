// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contributors_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContributorsManager)
final contributorsManagerProvider = ContributorsManagerProvider._();

final class ContributorsManagerProvider
    extends $AsyncNotifierProvider<ContributorsManager, List<Contributor>> {
  ContributorsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributorsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributorsManagerHash();

  @$internal
  @override
  ContributorsManager create() => ContributorsManager();
}

String _$contributorsManagerHash() =>
    r'89fa2532e956915392d5423525d9f025517e2ff6';

abstract class _$ContributorsManager extends $AsyncNotifier<List<Contributor>> {
  FutureOr<List<Contributor>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Contributor>>, List<Contributor>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Contributor>>, List<Contributor>>,
              AsyncValue<List<Contributor>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
