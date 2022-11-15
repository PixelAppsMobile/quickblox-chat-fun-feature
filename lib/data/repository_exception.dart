import 'dart:developer';

class RepositoryException implements Exception {
  String? _message;
  List<String>? _problemParameters;

  String get message => _buildErrorMessage();

  RepositoryException(this._message, {List<String>? affectedParams}) {
    _problemParameters = affectedParams;
  }

  String _buildErrorMessage() {
    _message ??= "Unexpected exception";
    String message = _message! +
        (_problemParameters == null
            ? ""
            : " : ${_problemParameters!.join(', ')}");
    log(message, name: "RepositoryException", level: 0);
    return message;
  }
}
