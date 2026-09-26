import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/data/models/report_dto.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/notifications/presentation/providers/notification_provider.dart';
import 'package:lost_and_found/features/notifications/data/models/notification_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/constants/app_constants.dart';

part 'admin_provider.g.dart';

@riverpod
Stream<List<Report>> allReports(AllReportsRef ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.reportsCollection)
      .snapshots()
      .map((snapshot) {
    print('DEBUG: allReports fetched ${snapshot.docs.length} documents');
    final reports = snapshot.docs
        .map((doc) => ReportDTO.fromFirestore(doc).toDomain())
        .toList();
    // Sort by createdAt in-memory to avoid needing index
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  });
}

@riverpod
class AdminReportNotifier extends _$AdminReportNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    state = const AsyncLoading();
    try {
      final reportDoc = await FirebaseFirestore.instance.collection('reports').doc(reportId).get();
      final report = ReportDTO.fromFirestore(reportDoc).toDomain();

      await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
        'status': status.name,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Send Notification to User
      final notification = NotificationDTO(
        id: '',
        userId: report.userId,
        title: 'Report Status Update',
        body: 'Your report for "${report.description}" is now ${status.name.toUpperCase()}.',
        timestamp: DateTime.now(),
        isRead: false,
        type: 'statusUpdate',
        relatedId: reportId,
      );
      
      await ref.read(notificationDatasourceProvider).sendNotification(notification);

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
