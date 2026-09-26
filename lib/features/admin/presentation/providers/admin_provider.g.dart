// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allReportsHash() => r'fa0514873feb7a908df7baef71310b246da7834d';

/// See also [allReports].
@ProviderFor(allReports)
final allReportsProvider = AutoDisposeStreamProvider<List<Report>>.internal(
  allReports,
  name: r'allReportsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allReportsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllReportsRef = AutoDisposeStreamProviderRef<List<Report>>;
String _$adminReportNotifierHash() =>
    r'083f1dc66ecbf9d7f2d0811f46e7b7d1120015d0';

/// See also [AdminReportNotifier].
@ProviderFor(AdminReportNotifier)
final adminReportNotifierProvider =
    AutoDisposeNotifierProvider<AdminReportNotifier, AsyncValue<void>>.internal(
  AdminReportNotifier.new,
  name: r'adminReportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminReportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminReportNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
