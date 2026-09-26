import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';

class ReportDTO {
  final String id;
  final String trackId;
  final String userId;
  final String userName;
  final String category;
  final String description;
  final String lostLocation;
  final DateTime lostDate;
  final String status;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  const ReportDTO({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.userName,
    required this.category,
    required this.description,
    required this.lostLocation,
    required this.lostDate,
    required this.status,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory ReportDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReportDTO(
      id: doc.id,
      trackId: data['trackId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      category: data['category']?.toString() ?? 'other',
      description: data['description']?.toString() ?? '',
      lostLocation: data['lostLocation']?.toString() ?? '',
      lostDate: _parseDate(data['lostDate']),
      status: data['status']?.toString() ?? 'pending',
      createdAt: _parseDate(data['createdAt']),
      lastUpdatedAt: _parseDate(data['lastUpdatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'userId': userId,
      'userName': userName,
      'category': category,
      'description': description,
      'lostLocation': lostLocation,
      'lostDate': Timestamp.fromDate(lostDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  Report toDomain() {
    return Report(
      id: id,
      trackId: trackId,
      userId: userId,
      userName: userName,
      category: ReportCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => ReportCategory.other,
      ),
      description: description,
      lostLocation: lostLocation,
      lostDate: lostDate,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ReportStatus.pending,
      ),
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
    );
  }
}
