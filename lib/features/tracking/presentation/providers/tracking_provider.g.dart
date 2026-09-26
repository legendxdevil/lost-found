// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trackReportUseCaseHash() =>
    r'beb17823df9eb9fc0036b742eb8575a6a4b8d6d8';

/// See also [trackReportUseCase].
@ProviderFor(trackReportUseCase)
final trackReportUseCaseProvider =
    AutoDisposeProvider<TrackReportUseCase>.internal(
  trackReportUseCase,
  name: r'trackReportUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackReportUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrackReportUseCaseRef = AutoDisposeProviderRef<TrackReportUseCase>;
String _$trackingNotifierHash() => r'c197321225b3e9fa803cc158c3cb8642a0167555';

/// See also [TrackingNotifier].
@ProviderFor(TrackingNotifier)
final trackingNotifierProvider =
    AutoDisposeNotifierProvider<TrackingNotifier, AsyncValue<Report?>>.internal(
  TrackingNotifier.new,
  name: r'trackingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrackingNotifier = AutoDisposeNotifier<AsyncValue<Report?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
