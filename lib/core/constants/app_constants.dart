class AppConstants {
  // App Info
  static const String appName = 'Lost & Found';
  
  // Admin Configuration
  static const List<String> adminEmails = [
    'admin@lostfound.com',
  ];
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String trackUpdatesCollection = 'trackUpdates';
  static const String trackUpdatesSubcollection = 'updates';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';
  static const String notificationsCollection = 'notifications';
  static const String notificationsItemsSubcollection = 'items';
  static const String metaCollection = 'meta';
  
  // Notifications
  static const String notificationChannelId = 'lost_found_channel';
  static const String notificationChannelName = 'Lost & Found Alerts';
  static const String notificationChannelDesc = 'Status updates and messages';
  
  // Tracking
  static const String trackIdPrefix = 'LF';
}
