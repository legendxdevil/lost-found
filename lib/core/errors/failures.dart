abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication Failure']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Document Not Found']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Failure']);
}
