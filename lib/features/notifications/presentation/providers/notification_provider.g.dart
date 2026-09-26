// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationDatasourceHash() =>
    r'2ad9214968c10ca08812abeda465572ce379e148';

/// See also [notificationDatasource].
@ProviderFor(notificationDatasource)
final notificationDatasourceProvider =
    AutoDisposeProvider<NotificationRemoteDatasource>.internal(
  notificationDatasource,
  name: r'notificationDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationDatasourceRef
    = AutoDisposeProviderRef<NotificationRemoteDatasource>;
String _$myNotificationsHash() => r'6ecdfc2ad8784dbe3ae6157daa2cbf562fbab021';

/// See also [myNotifications].
@ProviderFor(myNotifications)
final myNotificationsProvider =
    AutoDisposeStreamProvider<List<AppNotification>>.internal(
  myNotifications,
  name: r'myNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyNotificationsRef
    = AutoDisposeStreamProviderRef<List<AppNotification>>;
String _$notificationNotifierHash() =>
    r'e43d079c1b1628554b509749f08246f6a336685c';

/// See also [NotificationNotifier].
@ProviderFor(NotificationNotifier)
final notificationNotifierProvider = AutoDisposeNotifierProvider<
    NotificationNotifier, AsyncValue<void>>.internal(
  NotificationNotifier.new,
  name: r'notificationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
