# Lost & Found App — Complete Project Blueprint

> **Stack:** Flutter (Android) · Firebase Auth · Cloud Firestore · Firebase Cloud Messaging (FCM) · Riverpod · Go Router · Clean Architecture

---

## Table of Contents

1. [Project Summary](#1-project-summary)
2. [What Is NOT in This Project](#2-what-is-not-in-this-project)
3. [Tech Stack & Packages](#3-tech-stack--packages)
4. [Architecture Overview](#4-architecture-overview)
5. [Folder Structure](#5-folder-structure)
6. [Firebase Setup](#6-firebase-setup)
7. [Firestore Data Schema](#7-firestore-data-schema)
8. [FCM Notification System](#8-fcm-notification-system)
9. [Feature Breakdown](#9-feature-breakdown)
10. [Screen List — User App](#10-screen-list--user-app)
11. [Screen List — Admin Dashboard](#11-screen-list--admin-dashboard)
12. [UI/UX Guidelines](#12-uiux-guidelines)
13. [Navigation & Routing](#13-navigation--routing)
14. [Riverpod State Management](#14-riverpod-state-management)
15. [Domain Layer — Entities & Use Cases](#15-domain-layer--entities--use-cases)
16. [Tracking ID System](#16-tracking-id-system)
17. [Admin Role System](#17-admin-role-system)
18. [Security Rules](#18-firestore-security-rules)
19. [Deep Links](#19-deep-links)
20. [Future Scope](#20-future-scope)

---

## 1. Project Summary

**Lost & Found** ek Android app hai jisme users apna khoya hua saman report kar sakte hain. Har report ko ek unique **Tracking ID** milta hai. Admin dashboard se admin log reports manage karte hain, status update karte hain, aur directly users se **chat** kar sakte hain. Status change hone par user ko **targeted push notification** milti hai.

### Core User Journey

```
User registers → Submits lost item report
→ Gets unique Tracking ID (e.g. LF-2024-00431)
→ Can track status anytime via ID
→ Admin reviews → Updates status
→ User gets push notification of status change
→ User & Admin can chat in realtime
→ Item returned → Report closed
```

### Core Admin Journey

```
Admin logs in (special role) → Sees all incoming reports
→ Assigns Tracking ID (auto-generated) → Updates status
→ Sends targeted notification to specific user
→ Chats with user for more details
→ Marks item as returned/closed
→ Views analytics & report history
```

---

## 2. What Is NOT in This Project

Ye cheezein **intentionally exclude** ki gayi hain:

| Feature | Reason |
|---|---|
| Image upload | Server load avoid karna hai |
| Offline mode / local DB (Hive) | Complexity reduce karna hai |
| Email notifications | Sirf app push notifications use karni hain |
| Web dashboard (separate) | Admin Flutter app ke andar hi hoga |

---

## 3. Tech Stack & Packages

### `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.0.0

  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.18.0
  cloud_firestore: ^4.15.0
  firebase_messaging: ^14.7.0
  firebase_crashlytics: ^3.4.8
  firebase_analytics: ^10.8.0

  # Functional error handling
  fpdart: ^1.1.0

  # Utilities
  uuid: ^4.3.3
  qr_flutter: ^4.1.0          # QR code for tracking ID
  mobile_scanner: ^5.1.0      # QR scanner (admin side)
  intl: ^0.19.0               # Date formatting, l10n

  # UI/UX
  lottie: ^3.1.0              # Empty state animations
  shimmer: ^3.0.0             # Loading skeletons
  dynamic_color: ^1.7.0       # Material You theming
  google_fonts: ^6.2.1        # Plus Jakarta Sans

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.8
  flutter_lints: ^4.0.0
```

---

## 4. Architecture Overview

**Clean Architecture** with 3 layers per feature:

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│   Pages · Widgets · Riverpod Providers  │
├─────────────────────────────────────────┤
│           DOMAIN LAYER                  │
│   Entities · Use Cases · Repo Interfaces│
│       (Pure Dart — zero dependencies)   │
├─────────────────────────────────────────┤
│            DATA LAYER                   │
│   Firebase Datasources · DTOs · Mappers │
│       Repo Implementations              │
└─────────────────────────────────────────┘
```

### The Golden Rule

> Domain layer **never imports** Firebase, Flutter, or any external package.
> All dependencies point **inward only**.

### Data Flow

```
Widget (ConsumerWidget)
  └─ reads Provider
      └─ calls AsyncNotifier method
          └─ calls UseCase
              └─ calls Repository (abstract interface)
                  └─ RepoImpl calls Firebase Datasource
                      └─ Firestore / FCM / Auth
```

---

## 5. Folder Structure

```
lib/
├── main.dart
├── app.dart                          # ProviderScope + MaterialApp.router
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart          # all UI strings (l10n ready)
│   │   └── app_constants.dart        # timeouts, collection names
│   ├── errors/
│   │   ├── failures.dart             # ServerFailure, AuthFailure...
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── track_id_generator.dart   # "LF-YYYY-NNNNN"
│   │   └── validators.dart
│   ├── extensions/
│   │   └── string_extensions.dart
│   └── theme/
│       ├── app_theme.dart            # light + dark + dynamic color
│       └── app_text_styles.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_dto.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart        # abstract
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_email_usecase.dart
│   │   │       ├── sign_in_with_google_usecase.dart
│   │   │       ├── sign_up_usecase.dart
│   │   │       └── sign_out_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── splash_page.dart
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       ├── widgets/
│   │       │   ├── auth_text_field.dart
│   │       │   └── social_login_button.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   │
│   ├── report/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── report_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── report_dto.dart
│   │   │   └── repositories/
│   │   │       └── report_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── report.dart
│   │   │   ├── repositories/
│   │   │   │   └── report_repository.dart      # abstract
│   │   │   └── usecases/
│   │   │       ├── submit_report_usecase.dart
│   │   │       ├── get_my_reports_usecase.dart
│   │   │       └── get_report_by_id_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── submit_report_page.dart
│   │       │   └── report_detail_page.dart
│   │       ├── widgets/
│   │       │   ├── category_selector.dart
│   │       │   ├── report_card.dart
│   │       │   └── status_badge.dart
│   │       └── providers/
│   │           └── report_provider.dart
│   │
│   ├── tracking/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── tracking_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── track_update_dto.dart
│   │   │   └── repositories/
│   │   │       └── tracking_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── track_update.dart
│   │   │   ├── repositories/
│   │   │   │   └── tracking_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_track_status_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── tracking_page.dart
│   │       └── widgets/
│   │           ├── timeline_widget.dart         # animated vertical stepper
│   │           └── track_id_input_widget.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── chat_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── message_dto.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── message.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_message_usecase.dart
│   │   │       └── watch_messages_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── chat_page.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           └── chat_input_bar.dart
│   │
│   ├── notification/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── notification_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── notification_dto.dart
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_notification.dart
│   │   │   ├── repositories/
│   │   │   │   └── notification_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_notifications_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── notifications_page.dart
│   │       └── widgets/
│   │           └── notification_tile.dart
│   │
│   └── admin/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── admin_datasource.dart
│       │   ├── models/
│       │   │   └── admin_action_dto.dart
│       │   └── repositories/
│       │       └── admin_repository_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── admin_repository.dart
│       │   └── usecases/
│       │       ├── update_report_status_usecase.dart
│       │       ├── send_targeted_notification_usecase.dart
│       │       └── get_all_reports_usecase.dart
│       └── presentation/
│           ├── pages/
│           │   ├── admin_home_page.dart
│           │   ├── admin_reports_page.dart
│           │   ├── admin_report_detail_page.dart
│           │   ├── admin_chat_list_page.dart
│           │   ├── admin_send_notification_page.dart
│           │   └── admin_users_page.dart
│           ├── widgets/
│           │   ├── report_list_tile.dart
│           │   ├── status_update_sheet.dart
│           │   └── notification_composer_widget.dart
│           └── providers/
│               └── admin_provider.dart
│
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── loading_shimmer.dart
    │   ├── empty_state_widget.dart      # Lottie animation
    │   ├── app_error_widget.dart
    │   ├── track_id_badge.dart          # QR code + copy button
    │   └── custom_app_bar.dart
    └── providers/
        └── fcm_provider.dart            # FCM token management
```

---

## 6. Firebase Setup

### Services Required

| Service | Usage |
|---|---|
| **Firebase Auth** | Email/password + Google Sign-In |
| **Cloud Firestore** | All data storage |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Crashlytics** | Crash reporting |
| **Firebase Analytics** | Usage tracking |

### Setup Steps

```bash
# 1. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Login to Firebase
firebase login

# 3. Configure project (run from Flutter project root)
flutterfire configure --project=your-firebase-project-id

# 4. This creates lib/firebase_options.dart automatically
```

### `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FCM background handler registration
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: App()));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // handle background notification
}
```

### `AndroidManifest.xml` additions

```xml
<!-- Inside <application> tag -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="lost_found_channel"/>

<!-- Inside <activity> tag — for deep links -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https" android:host="lostfound.app"/>
</intent-filter>
```

---

## 7. Firestore Data Schema

### Collections Structure

```
firestore/
├── users/
│   └── {uid}/
│       ├── uid: string
│       ├── name: string
│       ├── email: string
│       ├── phone: string?
│       ├── fcmToken: string          ← updated on every login
│       ├── isAdmin: bool             ← set via Firebase Custom Claims
│       ├── createdAt: timestamp
│       └── reportCount: number
│
├── reports/
│   └── {reportId}/
│       ├── id: string
│       ├── trackId: string           ← "LF-2024-00431" (unique)
│       ├── userId: string            ← ref to users/{uid}
│       ├── userName: string          ← denormalized for admin view
│       ├── category: string          ← enum value
│       ├── description: string
│       ├── lostDate: timestamp
│       ├── lostLocation: string      ← text description of location
│       ├── status: string            ← pending|underReview|located|returned|closed
│       ├── createdAt: timestamp
│       └── lastUpdatedAt: timestamp
│
├── trackUpdates/
│   └── {reportId}/
│       └── updates/ (subcollection)
│           └── {updateId}/
│               ├── status: string
│               ├── message: string   ← admin ka note
│               ├── updatedBy: string ← admin uid
│               ├── timestamp: timestamp
│               └── notificationSent: bool
│
├── chats/
│   └── {chatId}/                     ← chatId = reportId (1:1 mapping)
│       ├── reportId: string
│       ├── userId: string
│       ├── adminId: string?
│       ├── lastMessage: string
│       ├── lastMessageAt: timestamp
│       ├── userUnread: number
│       ├── adminUnread: number
│       └── messages/ (subcollection)
│           └── {messageId}/
│               ├── senderId: string
│               ├── senderName: string
│               ├── text: string
│               ├── timestamp: timestamp
│               └── isRead: bool
│
└── notifications/
    └── {uid}/
        └── items/ (subcollection)
            └── {notifId}/
                ├── title: string
                ├── body: string
                ├── type: string      ← statusUpdate|chatMessage|adminAlert
                ├── reportId: string?
                ├── isRead: bool
                └── createdAt: timestamp
```

---

## 8. FCM Notification System

### How It Works

```
Admin updates report status (Firestore write)
    ↓
Admin app calls sendTargetedNotification(userId, title, body)
    ↓
Read FCM token from users/{uid}/fcmToken
    ↓
Call Firebase Admin SDK via Cloud Function
    ↓
FCM delivers notification to user's device
    ↓
Also write to notifications/{uid}/items/ (inbox history)
```

### FCM Token Management

Har baar user login kare, FCM token update ho:

```dart
// shared/providers/fcm_provider.dart
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeFcm(String uid) async {
    // Permission request (Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create notification channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'lost_found_channel',
      'Lost & Found Alerts',
      description: 'Status updates and messages',
      importance: Importance.high,
    );

    // Save/update FCM token in Firestore
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _firestore.collection('users').doc(uid).update({'fcmToken': newToken});
    });

    // Foreground notification handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show local notification using flutter_local_notifications
      // Also update notification badge count
    });

    // When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final reportId = message.data['reportId'];
      if (reportId != null) {
        // Navigate to tracking page with this reportId
      }
    });
  }
}
```

### Cloud Function — Send Targeted Notification

```javascript
// functions/index.js
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTargetedNotification = functions.https.onCall(async (data, context) => {
  // Verify caller is admin
  if (!context.auth?.token?.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admins only');
  }

  const { userId, title, body, reportId, type } = data;

  // Get user FCM token
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;

  if (!fcmToken) throw new functions.https.HttpsError('not-found', 'FCM token missing');

  // Send FCM notification
  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
    data: { reportId: reportId ?? '', type: type ?? 'general' },
    android: {
      priority: 'high',
      notification: {
        channelId: 'lost_found_channel',
        sound: 'default',
      },
    },
  });

  // Write to notification inbox
  await admin.firestore()
    .collection('notifications')
    .doc(userId)
    .collection('items')
    .add({
      title,
      body,
      type,
      reportId: reportId ?? null,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  return { success: true };
});
```

### How Admin Calls This Function (Flutter)

```dart
// admin/domain/usecases/send_targeted_notification_usecase.dart
class SendTargetedNotificationUseCase {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Either<Failure, Unit>> call(NotificationParams params) async {
    try {
      final callable = _functions.httpsCallable('sendTargetedNotification');
      await callable.call({
        'userId': params.userId,
        'title': params.title,
        'body': params.body,
        'reportId': params.reportId,
        'type': params.type.name,
      });
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
```

---

## 9. Feature Breakdown

### Feature 1: Authentication

- Email + password registration / login
- Google Sign-In
- Phone OTP (optional — can add later)
- Auth state persists across restarts
- On first login → save FCM token → navigate to Home
- Admin users get `isAdmin: true` via Custom Claims (set manually or via Cloud Function)

### Feature 2: Report Submission

- User selects category (Electronics, Documents, Keys, Bag, Wallet, Other)
- Fills description (min 20 chars)
- Selects approximate lost date
- Types location description (text — no map integration to keep it simple)
- Submits → Tracking ID auto-generated → shown with QR code
- Report saved to Firestore with `status: pending`

### Feature 3: Tracking

- User enters Tracking ID manually OR scans QR
- Realtime stream from Firestore shows current status
- Vertical animated timeline shows all status updates with admin messages
- Statuses: `Pending → Under Review → Located → Returned / Closed`

### Feature 4: Chat

- Each report has its own chat thread (chatId = reportId)
- Realtime messages via Firestore stream
- User sees chat icon on their report detail page
- Admin sees all chats in Chat Center tab
- Unread count badge shown

### Feature 5: Push Notifications (Targeted)

- Admin can send notification to **specific user** from report detail page
- Notification delivered via FCM to that user's device only
- Also stored in user's notification inbox in Firestore
- User sees notification bell with unread badge
- Tapping notification → opens relevant report tracking page

### Feature 6: Admin Dashboard

- Protected by Firebase Custom Claims check (`isAdmin: true`)
- Tabs: Overview · Reports · Chat Center · Notifications · Users
- Overview shows stats: total reports, pending, resolved today
- Reports page: filterable table (by status, date, category)
- Can update status with custom admin message
- Can send notification to specific user
- Can view all user chats

---

## 10. Screen List — User App

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | Auth state check, Lottie animation |
| Login | `/login` | Email + Google login |
| Register | `/register` | Name, email, password |
| Home | `/home` | User's reports summary, quick action buttons |
| Submit Report | `/report/submit` | Multi-step form — category → details → location → confirm |
| Report Detail | `/report/:id` | Full report view, status badge, chat button |
| Tracking | `/track` | Enter Track ID → see timeline |
| Tracking Result | `/track/:trackId` | Animated timeline of status updates |
| Chat | `/chat/:reportId` | Realtime chat with admin |
| Notifications | `/notifications` | Notification inbox |
| Profile | `/profile` | User info, my reports history, logout |

---

## 11. Screen List — Admin Dashboard

| Screen | Route | Description |
|---|---|---|
| Admin Home | `/admin` | Stats overview: pending/total/resolved |
| All Reports | `/admin/reports` | Filterable list of all reports |
| Report Detail | `/admin/reports/:id` | Full report, status updater, notify button |
| Chat Center | `/admin/chats` | All user conversations list |
| Chat Thread | `/admin/chats/:chatId` | Individual chat with user |
| Send Notification | `/admin/notify/:userId` | Compose targeted notification |
| Users | `/admin/users` | All registered users, report count |

---

## 12. UI/UX Guidelines

### Theme

```dart
// core/theme/app_theme.dart

// Font: Plus Jakarta Sans (Google Fonts)
// Primary color: Deep Teal (#0F6E56)
// Secondary: Coral (#D85A30)
// Background: #FAFAFA (light) / #121212 (dark)
// Surface cards: white with 1px border + 8px radius
// Support: Dynamic Color (Material You) on Android 12+
```

### Design Rules

- **Bottom Navigation Bar** — 4 tabs: Home · Track · Notifications · Profile
- **Floating Action Button** — on Home screen for quick "Report Lost Item"
- **Skeleton shimmer** instead of spinner while loading lists
- **Empty state** — Lottie animation on empty screens ("No reports yet")
- **Haptic feedback** on submit, copy Track ID, status update
- **Hero animation** on report card → report detail page
- **Animated timeline** on tracking page (draw animation on load)
- **Confetti animation** when status changes to "Returned"
- **Status chips** with color coding:
  - Pending → grey
  - Under Review → amber
  - Located → blue
  - Returned → green
  - Closed → red

### Track ID Badge Widget

```dart
// shared/widgets/track_id_badge.dart
// Shows: "LF-2024-00431" with:
//   - Copy to clipboard button (haptic feedback)
//   - QR code popup on tap
//   - Share button
```

---

## 13. Navigation & Routing

```dart
// app.dart — go_router setup

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authStateProvider).value != null;
    final isAdmin = ref.read(isAdminProvider);
    
    if (!isLoggedIn && state.uri.toString() != '/login') return '/login';
    if (isLoggedIn && isAdmin && !state.uri.toString().startsWith('/admin')) {
      return '/admin';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/report/submit', builder: (_, __) => const SubmitReportPage()),
        GoRoute(path: '/report/:id', builder: (_, state) =>
            ReportDetailPage(reportId: state.pathParameters['id']!)),
        GoRoute(path: '/track', builder: (_, __) => const TrackingPage()),
        GoRoute(path: '/track/:trackId', builder: (_, state) =>
            TrackingResultPage(trackId: state.pathParameters['trackId']!)),
        GoRoute(path: '/chat/:reportId', builder: (_, state) =>
            ChatPage(reportId: state.pathParameters['reportId']!)),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    // Admin routes — protected
    ShellRoute(
      builder: (_, __, child) => AdminScaffold(child: child),
      routes: [
        GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),
        GoRoute(path: '/admin/reports', builder: (_, __) => const AdminReportsPage()),
        GoRoute(path: '/admin/reports/:id', builder: (_, state) =>
            AdminReportDetailPage(reportId: state.pathParameters['id']!)),
        GoRoute(path: '/admin/chats', builder: (_, __) => const AdminChatListPage()),
        GoRoute(path: '/admin/chats/:chatId', builder: (_, state) =>
            AdminChatPage(chatId: state.pathParameters['chatId']!)),
        GoRoute(path: '/admin/notify/:userId', builder: (_, state) =>
            AdminSendNotificationPage(userId: state.pathParameters['userId']!)),
        GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersPage()),
      ],
    ),
  ],
);
```

---

## 14. Riverpod State Management

### Pattern Used

- `AsyncNotifierProvider` for all async operations (submit, fetch)
- `StreamProvider` for realtime Firestore streams (chat, tracking)
- `Provider` for use cases and repositories (dependency injection)
- `StateProvider` for simple UI state (selected tab, filter)

### Example — Report Provider

```dart
// features/report/presentation/providers/report_provider.dart

// DI
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDatasource: ReportRemoteDatasource(FirebaseFirestore.instance),
  );
});

final submitReportUseCaseProvider = Provider((ref) =>
    SubmitReportUseCase(ref.watch(reportRepositoryProvider)));

final getMyReportsUseCaseProvider = Provider((ref) =>
    GetMyReportsUseCase(ref.watch(reportRepositoryProvider)));

// State
@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  AsyncValue<List<Report>> build() => const AsyncData([]);

  Future<void> loadMyReports(String userId) async {
    state = const AsyncLoading();
    final result = await ref.read(getMyReportsUseCaseProvider)(userId);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (reports) => AsyncData(reports),
    );
  }

  Future<String?> submitReport(SubmitReportParams params) async {
    final result = await ref.read(submitReportUseCaseProvider)(params);
    return result.fold(
      (failure) { state = AsyncError(failure.message, StackTrace.current); return null; },
      (report) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([report, ...current]);
        return report.trackId;
      },
    );
  }
}

// Realtime tracking stream
final trackingStreamProvider = StreamProvider.family<Report?, String>((ref, trackId) {
  return ref.watch(trackingRepositoryProvider).watchReportByTrackId(trackId);
});

// Chat stream
final chatStreamProvider = StreamProvider.family<List<Message>, String>((ref, reportId) {
  return ref.watch(chatRepositoryProvider).watchMessages(reportId);
});
```

---

## 15. Domain Layer — Entities & Use Cases

### `report.dart` entity

```dart
class Report {
  final String id;
  final String trackId;          // "LF-2024-00431"
  final String userId;
  final String userName;
  final ReportCategory category;
  final String description;
  final String lostLocation;
  final DateTime lostDate;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  const Report({ required this.id, required this.trackId, required this.userId,
    required this.userName, required this.category, required this.description,
    required this.lostLocation, required this.lostDate, required this.status,
    required this.createdAt, required this.lastUpdatedAt });
}

enum ReportCategory { electronics, documents, keys, bag, wallet, other }
enum ReportStatus { pending, underReview, located, returned, closed }
```

### `app_user.dart` entity

```dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? fcmToken;
  final bool isAdmin;
  final DateTime createdAt;

  const AppUser({ required this.uid, required this.name, required this.email,
    this.phone, this.fcmToken, required this.isAdmin, required this.createdAt });
}
```

### `message.dart` entity

```dart
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const Message({ required this.id, required this.senderId, required this.senderName,
    required this.text, required this.timestamp, required this.isRead });
}
```

### `track_update.dart` entity

```dart
class TrackUpdate {
  final String id;
  final ReportStatus status;
  final String message;
  final String updatedBy;
  final DateTime timestamp;

  const TrackUpdate({ required this.id, required this.status, required this.message,
    required this.updatedBy, required this.timestamp });
}
```

### Report Repository Interface

```dart
abstract class ReportRepository {
  Future<Either<Failure, Report>> submitReport(SubmitReportParams params);
  Future<Either<Failure, List<Report>>> getMyReports(String userId);
  Future<Either<Failure, Report>> getReportByTrackId(String trackId);
  Stream<Report> watchReport(String reportId);
}
```

---

## 16. Tracking ID System

### Format

```
LF - YYYY - NNNNN
│    │      └── 5-digit zero-padded number (auto-increment simulation)
│    └────────── current year
└────────────── "Lost & Found" prefix
```

Example: `LF-2024-00431`

### Generator

```dart
// core/utils/track_id_generator.dart
class TrackIdGenerator {
  static String generate() {
    final year = DateTime.now().year;
    // Random 5-digit number — chance of collision is very low for small apps
    // For production: use Firestore counter or timestamp-based
    final number = Random().nextInt(89999) + 10000;
    return 'LF-$year-$number';
  }

  // For production: increment-based
  static Future<String> generateUnique(FirebaseFirestore db) async {
    final counterRef = db.collection('meta').doc('reportCounter');
    return db.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      final count = (snap.data()?['count'] ?? 0) + 1;
      tx.set(counterRef, {'count': count});
      final year = DateTime.now().year;
      return 'LF-$year-${count.toString().padLeft(5, '0')}';
    });
  }
}
```

---

## 17. Admin Role System

### Setting Admin Role (Firebase Custom Claims)

```javascript
// Cloud Function — callable by super admin only
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Only existing admins can create new admins
  if (!context.auth?.token?.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admins only');
  }
  await admin.auth().setCustomUserClaims(data.uid, { admin: true });
  await admin.firestore().collection('users').doc(data.uid).update({ isAdmin: true });
  return { success: true };
});
```

### Checking Admin Role in Flutter

```dart
// features/auth/presentation/providers/auth_provider.dart
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final tokenResult = await user.getIdTokenResult();
  return tokenResult.claims?['admin'] == true;
});
```

### Admin Route Guard

```dart
// In GoRouter redirect:
final tokenResult = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
final isAdmin = tokenResult?.claims?['admin'] == true;

if (state.uri.toString().startsWith('/admin') && !isAdmin) {
  return '/home'; // redirect non-admins away from admin routes
}
```

---

## 18. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isLoggedIn() {
      return request.auth != null;
    }
    function isAdmin() {
      return isLoggedIn() && request.auth.token.admin == true;
    }
    function isOwner(userId) {
      return isLoggedIn() && request.auth.uid == userId;
    }

    // Users — can only read/write own document, admin reads all
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow write: if isOwner(userId) || isAdmin();
    }

    // Reports — user creates own, reads own; admin reads and updates all
    match /reports/{reportId} {
      allow create: if isLoggedIn() && request.resource.data.userId == request.auth.uid;
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // Track updates — user reads own report's updates, admin writes
    match /trackUpdates/{reportId}/updates/{updateId} {
      allow read: if isLoggedIn();  // anyone can read if they have trackId
      allow write: if isAdmin();
    }

    // Chats — only the report owner and admin
    match /chats/{chatId} {
      allow read, write: if isLoggedIn() && (
        isOwner(resource.data.userId) || isAdmin()
      );
      match /messages/{messageId} {
        allow read, write: if isLoggedIn() && (
          isOwner(get(/databases/$(database)/documents/chats/$(chatId)).data.userId)
          || isAdmin()
        );
      }
    }

    // Notifications — only the target user and admin
    match /notifications/{userId}/items/{notifId} {
      allow read, write: if isOwner(userId) || isAdmin();
    }
  }
}
```

---

## 19. Deep Links

Deep link format: `https://lostfound.app/track/LF-2024-00431`

Tapping this link opens the app directly on the tracking page.

```dart
// In GoRouter — handle incoming deep links
final router = GoRouter(
  // GoRouter automatically handles deep links if you configure
  // the intent filter in AndroidManifest.xml (already done above)
  routes: [
    GoRoute(
      path: '/track/:trackId',
      builder: (_, state) => TrackingResultPage(
        trackId: state.pathParameters['trackId']!,
      ),
    ),
  ],
);
```

---

## 20. Future Scope

Features that are **NOT** in v1 but can be added later:

| Feature | Notes |
|---|---|
| Image upload | Add Firebase Storage + flutter_image_compress when ready |
| Offline mode | Add Hive local DB + sync logic |
| Email notifications | Firebase Extension "Trigger Email" |
| Web public tracking page | Flutter Web or simple HTML page on Firebase Hosting |
| Google Maps location picker | Replace text location input |
| Multi-language (Hindi/English) | Add intl + ARB files |
| QR scanner for admin | mobile_scanner already in pubspec — just build the screen |
| Report expiry Cloud Function | Auto-close reports after 90 days |
| Duplicate detection | Cloud Function checks category + location on new reports |

---

## Quick Start Commands

```bash
# Create Flutter project
flutter create lost_and_found --org com.yourname

# Add all packages
flutter pub add flutter_riverpod riverpod_annotation go_router \
  firebase_core firebase_auth cloud_firestore firebase_messaging \
  firebase_crashlytics firebase_analytics fpdart uuid qr_flutter \
  mobile_scanner intl lottie shimmer dynamic_color google_fonts

# Add dev dependencies
flutter pub add --dev riverpod_generator build_runner flutter_lints

# Configure Firebase
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# Run code generation (Riverpod + Hive)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

*Document version: 1.0 | Last updated: April 2026*
*Project: Lost & Found Flutter App*
