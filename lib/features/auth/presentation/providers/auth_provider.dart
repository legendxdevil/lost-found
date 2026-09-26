import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';
import 'package:lost_and_found/features/auth/domain/repositories/auth_repository.dart';
import 'package:lost_and_found/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lost_and_found/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lost_and_found/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:lost_and_found/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:lost_and_found/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:lost_and_found/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:lost_and_found/core/usecases/usecase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lost_and_found/core/errors/exceptions.dart';
import 'package:lost_and_found/core/constants/app_constants.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    AuthRemoteDatasourceImpl(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
  );
}

@Riverpod(keepAlive: true)
SignInWithEmailUseCase signInWithEmailUseCase(Ref ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignUpUseCase signUpUseCase(Ref ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

@Riverpod(keepAlive: true)
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
Stream<User?> firebaseUser(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
Stream<AppUser?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
Future<AppUser?> currentUser(Ref ref) async {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return null;
  return ref.watch(authRepositoryProvider).getCurrentUser();
}

@riverpod
Future<bool> isAdmin(Ref ref) async {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  if (user == null) return false;
  
  // Check custom claims
  final idToken = await user.getIdTokenResult(true);
  if (idToken.claims?['admin'] == true) return true;
  
  // Check email whitelist for development (case-insensitive)
  final email = user.email?.toLowerCase();
  if (email == null) return false;
  return AppConstants.adminEmails.any((e) => e.toLowerCase() == email);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(signInWithEmailUseCaseProvider).call(email, password).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw AuthException('Connection timeout. Please check your network and try again.'),
      );
      
      result.fold(
        (failure) => state = AsyncError(failure.message, StackTrace.current),
        (user) async {
          await _updateFcmToken(user.uid);
          state = const AsyncData(null);
        },
      );
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  Future<void> googleLogin() async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithGoogleUseCaseProvider).call(NoParams());
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) async {
        await _updateFcmToken(user.uid);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(signUpUseCaseProvider).call(name, email, password);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) async {
        await _updateFcmToken(user.uid);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await ref.read(signOutUseCaseProvider).call();
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  Future<void> _updateFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ref.read(authRepositoryProvider).updateFcmToken(uid, token);
      }
    } catch (e) {
      print('FCM Token update skipped (likely permission blocked): $e');
    }
  }
}
