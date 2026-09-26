import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/domain/repositories/report_repository.dart';

class GetReportByIdUseCase {
  final ReportRepository _repository;

  GetReportByIdUseCase(this._repository);

  Future<Either<Failure, Report>> call(String reportId) async {
    return await _repository.getReportById(reportId);
  }
}
