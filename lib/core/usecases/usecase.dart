import 'package:fpdart/fpdart.dart';
import 'package:lost_and_found/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
