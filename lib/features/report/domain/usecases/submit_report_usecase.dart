import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/domain/repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repository;

  SubmitReportUseCase(this._repository);

  Future<Either<Failure, Report>> call({
    required String userId,
    required String userName,
    required ReportCategory category,
    required String description,
    required String lostLocation,
    required DateTime lostDate,
  }) async {
    return await _repository.submitReport(
      userId: userId,
      userName: userName,
      category: category,
      description: description,
      lostLocation: lostLocation,
      lostDate: lostDate,
    );
  }
}
