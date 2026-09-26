import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/core/errors/exceptions.dart';
import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';
import 'package:lost_and_found/features/auth/domain/repositories/auth_repository.dart';
import 'package:lost_and_found/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password) async {
    try {
      final userDto = await _remoteDatasource.signInWithEmail(email, password);
      return right(userDto.toDomain());
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp(String name, String email, String password) async {
    try {
      final userDto = await _remoteDatasource.signUp(name, email, password);
      return right(userDto.toDomain());
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final userDto = await _remoteDatasource.signInWithGoogle();
      return right(userDto.toDomain());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDatasource.signOut();
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<AppUser?> get authStateChanges => 
      _remoteDatasource.authStateChanges.map((dto) => dto?.toDomain());

  @override
  Future<AppUser?> getCurrentUser() async {
    final dto = await _remoteDatasource.getCurrentUser();
    return dto?.toDomain();
  }

  @override
  Future<Either<Failure, Unit>> updateFcmToken(String uid, String token) async {
    try {
      await _remoteDatasource.updateFcmToken(uid, token);
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
