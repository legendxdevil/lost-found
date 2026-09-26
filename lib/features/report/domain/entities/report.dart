enum ReportCategory { electronics, documents, keys, bag, wallet, other }

enum ReportStatus { pending, underReview, located, returned, closed }

class Report {
  final String id;
  final String trackId;
  final String userId;
  final String userName;
  final ReportCategory category;
  final String description;
  final String lostLocation;
  final DateTime lostDate;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  const Report({
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
}
