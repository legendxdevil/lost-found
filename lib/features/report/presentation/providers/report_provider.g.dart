// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportRepositoryHash() => r'e4a1d493975006b897c8fc6831219cb1783edaaa';

/// See also [reportRepository].
@ProviderFor(reportRepository)
final reportRepositoryProvider = Provider<ReportRepository>.internal(
  reportRepository,
  name: r'reportRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportRepositoryRef = ProviderRef<ReportRepository>;
String _$submitReportUseCaseHash() =>
    r'babf13bf158b4001bcb83e29c35e3a506fb93a91';

/// See also [submitReportUseCase].
@ProviderFor(submitReportUseCase)
final submitReportUseCaseProvider = Provider<SubmitReportUseCase>.internal(
  submitReportUseCase,
  name: r'submitReportUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$submitReportUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubmitReportUseCaseRef = ProviderRef<SubmitReportUseCase>;
String _$getMyReportsUseCaseHash() =>
    r'a4cf1ed56590ac772329096880a48bb18904a3b7';

/// See also [getMyReportsUseCase].
@ProviderFor(getMyReportsUseCase)
final getMyReportsUseCaseProvider = Provider<GetMyReportsUseCase>.internal(
  getMyReportsUseCase,
  name: r'getMyReportsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getMyReportsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMyReportsUseCaseRef = ProviderRef<GetMyReportsUseCase>;
String _$getReportByIdUseCaseHash() =>
    r'057ac780f340d06f3846e296757f5d0ef5e2c04b';

/// See also [getReportByIdUseCase].
@ProviderFor(getReportByIdUseCase)
final getReportByIdUseCaseProvider = Provider<GetReportByIdUseCase>.internal(
  getReportByIdUseCase,
  name: r'getReportByIdUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getReportByIdUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetReportByIdUseCaseRef = ProviderRef<GetReportByIdUseCase>;
String _$myReportsHash() => r'62308392b206e495af973cde46c2eb56e393bff1';

/// See also [myReports].
@ProviderFor(myReports)
final myReportsProvider =
    AutoDisposeProvider<AsyncValue<List<Report>>>.internal(
  myReports,
  name: r'myReportsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myReportsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyReportsRef = AutoDisposeProviderRef<AsyncValue<List<Report>>>;
String _$watchReportHash() => r'550730ef8c478f5ea92e844c16bc01b3e640b6f2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [watchReport].
@ProviderFor(watchReport)
const watchReportProvider = WatchReportFamily();

/// See also [watchReport].
class WatchReportFamily extends Family<AsyncValue<Report>> {
  /// See also [watchReport].
  const WatchReportFamily();

  /// See also [watchReport].
  WatchReportProvider call(
    String reportId,
  ) {
    return WatchReportProvider(
      reportId,
    );
  }

  @override
  WatchReportProvider getProviderOverride(
    covariant WatchReportProvider provider,
  ) {
    return call(
      provider.reportId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'watchReportProvider';
}

/// See also [watchReport].
class WatchReportProvider extends AutoDisposeStreamProvider<Report> {
  /// See also [watchReport].
  WatchReportProvider(
    String reportId,
  ) : this._internal(
          (ref) => watchReport(
            ref as WatchReportRef,
            reportId,
          ),
          from: watchReportProvider,
          name: r'watchReportProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$watchReportHash,
          dependencies: WatchReportFamily._dependencies,
          allTransitiveDependencies:
              WatchReportFamily._allTransitiveDependencies,
          reportId: reportId,
        );

  WatchReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  Override overrideWith(
    Stream<Report> Function(WatchReportRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchReportProvider._internal(
        (ref) => create(ref as WatchReportRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Report> createElement() {
    return _WatchReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchReportProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchReportRef on AutoDisposeStreamProviderRef<Report> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _WatchReportProviderElement
    extends AutoDisposeStreamProviderElement<Report> with WatchReportRef {
  _WatchReportProviderElement(super.provider);

  @override
  String get reportId => (origin as WatchReportProvider).reportId;
}

String _$reportNotifierHash() => r'18d70d5a78d1fbd6b8117f47bc2ae9c4e72d5824';

/// See also [ReportNotifier].
@ProviderFor(ReportNotifier)
final reportNotifierProvider = AutoDisposeNotifierProvider<ReportNotifier,
    AsyncValue<List<Report>>>.internal(
  ReportNotifier.new,
  name: r'reportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportNotifier = AutoDisposeNotifier<AsyncValue<List<Report>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
