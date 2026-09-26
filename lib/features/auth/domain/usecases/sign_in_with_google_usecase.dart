import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';
import 'package:lost_and_found/core/usecases/usecase.dart';
import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';
import 'package:lost_and_found/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase implements UseCase<AppUser, NoParams> {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
