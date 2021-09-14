class HttpException implements Exception {
  String message;
  HttpException(this.message);

  @override
  String toString() {
    print(message);
    return message;
  }
}
