import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/domain/repositories/report_repository.dart';

class GetMyReportsUseCase {
  final ReportRepository _repository;

  GetMyReportsUseCase(this._repository);

  Future<Either<Failure, List<Report>>> call(String userId) async {
    return await _repository.getMyReports(userId);
  }
}
