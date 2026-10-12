// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsScrollIndex)
final settingsScrollIndexProvider = SettingsScrollIndexProvider._();

final class SettingsScrollIndexProvider
    extends $NotifierProvider<SettingsScrollIndex, int> {
  SettingsScrollIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsScrollIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsScrollIndexHash();

  @$internal
  @override
  SettingsScrollIndex create() => SettingsScrollIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$settingsScrollIndexHash() =>
    r'1a8936fe5ef2d319cc763b21abb4ac69eddc1435';

abstract class _$SettingsScrollIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SettingsBoolManager)
final settingsBoolManagerProvider = SettingsBoolManagerFamily._();

final class SettingsBoolManagerProvider
    extends $NotifierProvider<SettingsBoolManager, bool?> {
  SettingsBoolManagerProvider._({
    required SettingsBoolManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsBoolManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsBoolManagerHash();

  @override
  String toString() {
    return r'settingsBoolManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsBoolManager create() => SettingsBoolManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsBoolManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsBoolManagerHash() =>
    r'421b402f8e26b291d48da68a7e00cfca927404d7';

final class SettingsBoolManagerFamily extends $Family
    with
        $ClassFamilyOverride<SettingsBoolManager, bool?, bool?, bool?, String> {
  SettingsBoolManagerFamily._()
    : super(
        retry: null,
        name: r'settingsBoolManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsBoolManagerProvider call(String key) =>
      SettingsBoolManagerProvider._(argument: key, from: this);

  @override
  String toString() => r'settingsBoolManagerProvider';
}

abstract class _$SettingsBoolManager extends $Notifier<bool?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  bool? build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool?, bool?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool?, bool?>,
              bool?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SettingsIntManager)
final settingsIntManagerProvider = SettingsIntManagerFamily._();

final class SettingsIntManagerProvider
    extends $NotifierProvider<SettingsIntManager, int?> {
  SettingsIntManagerProvider._({
    required SettingsIntManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsIntManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsIntManagerHash();

  @override
  String toString() {
    return r'settingsIntManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsIntManager create() => SettingsIntManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsIntManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsIntManagerHash() =>
    r'3d8cf73a75a4a70db6c7c1738ead253379d0e5fb';

final class SettingsIntManagerFamily extends $Family
    with $ClassFamilyOverride<SettingsIntManager, int?, int?, int?, String> {
  SettingsIntManagerFamily._()
    : super(
        retry: null,
        name: r'settingsIntManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsIntManagerProvider call(String key) =>
      SettingsIntManagerProvider._(argument: key, from: this);

  @override
  String toString() => r'settingsIntManagerProvider';
}

abstract class _$SettingsIntManager extends $Notifier<int?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  int? build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SettingsDoubleManager)
final settingsDoubleManagerProvider = SettingsDoubleManagerFamily._();

final class SettingsDoubleManagerProvider
    extends $NotifierProvider<SettingsDoubleManager, double?> {
  SettingsDoubleManagerProvider._({
    required SettingsDoubleManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsDoubleManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsDoubleManagerHash();

  @override
  String toString() {
    return r'settingsDoubleManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsDoubleManager create() => SettingsDoubleManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsDoubleManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsDoubleManagerHash() =>
    r'cb3e08df1a6a00b15992fc0aa08ab442bc27854b';

final class SettingsDoubleManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          SettingsDoubleManager,
          double?,
          double?,
          double?,
          String
        > {
  SettingsDoubleManagerFamily._()
    : super(
        retry: null,
        name: r'settingsDoubleManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsDoubleManagerProvider call(String key) =>
      SettingsDoubleManagerProvider._(argument: key, from: this);

  @override
  String toString() => r'settingsDoubleManagerProvider';
}

abstract class _$SettingsDoubleManager extends $Notifier<double?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  double? build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double?, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double?, double?>,
              double?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SettingsStringManager)
final settingsStringManagerProvider = SettingsStringManagerFamily._();

final class SettingsStringManagerProvider
    extends $NotifierProvider<SettingsStringManager, String?> {
  SettingsStringManagerProvider._({
    required SettingsStringManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsStringManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsStringManagerHash();

  @override
  String toString() {
    return r'settingsStringManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsStringManager create() => SettingsStringManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsStringManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsStringManagerHash() =>
    r'f318a2b4dee61f883d84c28d7ba56f03fb227acf';

final class SettingsStringManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          SettingsStringManager,
          String?,
          String?,
          String?,
          String
        > {
  SettingsStringManagerFamily._()
    : super(
        retry: null,
        name: r'settingsStringManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsStringManagerProvider call(String key) =>
      SettingsStringManagerProvider._(argument: key, from: this);

  @override
  String toString() => r'settingsStringManagerProvider';
}

abstract class _$SettingsStringManager extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  String? build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SettingsStringListManager)
final settingsStringListManagerProvider = SettingsStringListManagerFamily._();

final class SettingsStringListManagerProvider
    extends $NotifierProvider<SettingsStringListManager, List<String>?> {
  SettingsStringListManagerProvider._({
    required SettingsStringListManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'settingsStringListManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsStringListManagerHash();

  @override
  String toString() {
    return r'settingsStringListManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsStringListManager create() => SettingsStringListManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsStringListManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsStringListManagerHash() =>
    r'f4828916222784aa9094ac6db7161714ef2701ab';

final class SettingsStringListManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          SettingsStringListManager,
          List<String>?,
          List<String>?,
          List<String>?,
          String
        > {
  SettingsStringListManagerFamily._()
    : super(
        retry: null,
        name: r'settingsStringListManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsStringListManagerProvider call(String key) =>
      SettingsStringListManagerProvider._(argument: key, from: this);

  @override
  String toString() => r'settingsStringListManagerProvider';
}

abstract class _$SettingsStringListManager extends $Notifier<List<String>?> {
  late final _$args = ref.$arg as String;
  String get key => _$args;

  List<String>? build(String key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>?, List<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>?, List<String>?>,
              List<String>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
