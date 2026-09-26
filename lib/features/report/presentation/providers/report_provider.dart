import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/domain/repositories/report_repository.dart';
import 'package:lost_and_found/features/report/data/repositories/report_repository_impl.dart';
import 'package:lost_and_found/features/report/data/datasources/report_remote_datasource.dart';
import 'package:lost_and_found/features/report/domain/usecases/submit_report_usecase.dart';
import 'package:lost_and_found/features/report/domain/usecases/get_my_reports_usecase.dart';
import 'package:lost_and_found/features/report/domain/usecases/get_report_by_id_usecase.dart';
import 'package:lost_and_found/features/auth/presentation/providers/auth_provider.dart';

part 'report_provider.g.dart';

@Riverpod(keepAlive: true)
ReportRepository reportRepository(ReportRepositoryRef ref) {
  return ReportRepositoryImpl(
    ReportRemoteDatasourceImpl(FirebaseFirestore.instance),
  );
}

@Riverpod(keepAlive: true)
SubmitReportUseCase submitReportUseCase(SubmitReportUseCaseRef ref) {
  return SubmitReportUseCase(ref.watch(reportRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetMyReportsUseCase getMyReportsUseCase(GetMyReportsUseCaseRef ref) {
  return GetMyReportsUseCase(ref.watch(reportRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetReportByIdUseCase getReportByIdUseCase(GetReportByIdUseCaseRef ref) {
  return GetReportByIdUseCase(ref.watch(reportRepositoryProvider));
}

@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  AsyncValue<List<Report>> build() {
    Future.microtask(() => _loadInitialReports());
    return const AsyncLoading();
  }

  Future<void> _loadInitialReports() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    final result = await ref.read(getMyReportsUseCaseProvider).call(user.uid);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (reports) => AsyncData(reports),
    );
  }

  Future<Report?> submitReport({
    required ReportCategory category,
    required String description,
    required String lostLocation,
    required DateTime lostDate,
  }) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncLoading();
    final result = await ref.read(submitReportUseCaseProvider).call(
      userId: user.uid,
      userName: user.name,
      category: category,
      description: description,
      lostLocation: lostLocation,
      lostDate: lostDate,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (report) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([report, ...current]);
        return report;
      },
    );
  }
}

@riverpod
AsyncValue<List<Report>> myReports(MyReportsRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const AsyncData([]);
  return ref.watch(reportNotifierProvider);
}

@riverpod
Stream<Report> watchReport(WatchReportRef ref, String reportId) {
  return ref.watch(reportRepositoryProvider).watchReport(reportId);
}
