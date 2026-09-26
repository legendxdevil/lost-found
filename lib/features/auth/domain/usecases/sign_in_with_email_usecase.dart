import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';
import 'package:lost_and_found/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<Either<Failure, AppUser>> call(String email, String password) async {
    return await _repository.signInWithEmail(email, password);
  }
}
