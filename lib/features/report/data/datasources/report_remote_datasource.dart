import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/errors/exceptions.dart';
import 'package:lost_and_found/features/report/data/models/report_dto.dart';
import 'package:lost_and_found/core/constants/app_constants.dart';
import 'package:lost_and_found/core/utils/track_id_generator.dart';

abstract class ReportRemoteDatasource {
  Future<ReportDTO> submitReport(ReportDTO reportDto);
  Future<List<ReportDTO>> getMyReports(String userId);
  Future<ReportDTO> getReportById(String reportId);
  Future<ReportDTO> getReportByTrackId(String trackId);
  Stream<ReportDTO> watchReport(String reportId);
}

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  final FirebaseFirestore _db;

  ReportRemoteDatasourceImpl(this._db);

  @override
  Future<ReportDTO> submitReport(ReportDTO reportDto) async {
    try {
      // Logic for trackId generation would ideally be here or passed in
      // Let's generate it using the generator
      final trackId = TrackIdGenerator.generate();
      
      final reportWithId = ReportDTO(
        id: reportDto.id, // This will be the doc id
        trackId: trackId,
        userId: reportDto.userId,
        userName: reportDto.userName,
        category: reportDto.category,
        description: reportDto.description,
        lostLocation: reportDto.lostLocation,
        lostDate: reportDto.lostDate,
        status: reportDto.status,
        createdAt: reportDto.createdAt,
        lastUpdatedAt: reportDto.lastUpdatedAt,
      );

      final docRef = _db.collection(AppConstants.reportsCollection).doc();
      final finalReport = ReportDTO(
        id: docRef.id,
        trackId: reportWithId.trackId,
        userId: reportWithId.userId,
        userName: reportWithId.userName,
        category: reportWithId.category,
        description: reportWithId.description,
        lostLocation: reportWithId.lostLocation,
        lostDate: reportWithId.lostDate,
        status: reportWithId.status,
        createdAt: reportWithId.createdAt,
        lastUpdatedAt: reportWithId.lastUpdatedAt,
      );

      await docRef.set(finalReport.toMap());
      return finalReport;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ReportDTO>> getMyReports(String userId) async {
    try {
      final query = await _db
          .collection(AppConstants.reportsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final reports = query.docs.map((doc) => ReportDTO.fromFirestore(doc)).toList();
      // Sort in memory to avoid needing a composite index
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReportDTO> getReportById(String reportId) async {
    try {
      final doc = await _db.collection(AppConstants.reportsCollection).doc(reportId).get();
      if (!doc.exists) throw const NotFoundException('Report not found');
      return ReportDTO.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReportDTO> getReportByTrackId(String trackId) async {
    try {
      final query = await _db
          .collection(AppConstants.reportsCollection)
          .where('trackId', isEqualTo: trackId)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) throw const NotFoundException('Report with status Tracking ID not found');
      return ReportDTO.fromFirestore(query.docs.first);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<ReportDTO> watchReport(String reportId) {
    return _db
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .snapshots()
        .map((doc) => ReportDTO.fromFirestore(doc));
  }
}
