import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lost_and_found/features/tracking/domain/usecases/track_report_usecase.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';

part 'tracking_provider.g.dart';

@riverpod
TrackReportUseCase trackReportUseCase(TrackReportUseCaseRef ref) {
  return TrackReportUseCase(ref.watch(reportRepositoryProvider));
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  @override
  AsyncValue<Report?> build() => const AsyncData(null);

  Future<void> trackItem(String trackId) async {
    state = const AsyncLoading();
    final result = await ref.read(trackReportUseCaseProvider).call(trackId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (report) => AsyncData(report),
    );
  }
}
