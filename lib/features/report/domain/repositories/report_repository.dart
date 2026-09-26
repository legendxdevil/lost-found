import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> submitReport({
    required String userId,
    required String userName,
    required ReportCategory category,
    required String description,
    required String lostLocation,
    required DateTime lostDate,
  });
  
  Future<Either<Failure, List<Report>>> getMyReports(String userId);
  Future<Either<Failure, Report>> getReportById(String reportId);
  Future<Either<Failure, Report>> getReportByTrackId(String trackId);
  Stream<Report> watchReport(String reportId);
}
