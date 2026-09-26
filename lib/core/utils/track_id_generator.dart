import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class TrackIdGenerator {
  /// Generates a random Tracking ID: LF-YYYY-NNNNN
  static String generate() {
    final year = DateTime.now().year;
    // Random 5-digit number
    final number = Random().nextInt(89999) + 10000;
    return '${AppConstants.trackIdPrefix}-$year-$number';
  }

  /// Generates a strictly unique sequential Tracking ID using a Firestore transaction.
  /// This ensures no collisions and sequential numbering.
  static Future<String> generateUnique(FirebaseFirestore db) async {
    final counterRef = db.collection(AppConstants.metaCollection).doc('reportCounter');
    
    return db.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      final count = (snap.data()?['count'] ?? 0) + 1;
      
      // Update counter in transaction
      tx.set(counterRef, {'count': count}, SetOptions(merge: true));
      
      final year = DateTime.now().year;
      final paddedCount = count.toString().padLeft(5, '0');
      
      return '${AppConstants.trackIdPrefix}-$year-$paddedCount';
    });
  }
}
