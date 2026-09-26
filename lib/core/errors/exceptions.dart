class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server Error']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication Error']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not Found Error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache Error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network Error']);
}
