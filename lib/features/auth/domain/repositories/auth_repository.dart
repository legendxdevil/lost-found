import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> signUp(String name, String email, String password);
  Future<Either<Failure, Unit>> signOut();
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> getCurrentUser();
  Future<Either<Failure, Unit>> updateFcmToken(String uid, String token);
}
