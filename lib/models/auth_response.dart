// lib/models/auth_response.dart

class AuthResponse {
  final String? message;
  final String? accessToken;
  final String? tokenType;
  final Map<String, List<String>>? errors;

  AuthResponse({this.message, this.accessToken, this.tokenType, this.errors});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? errorsMap;
    if (json.containsKey('errors') && json['errors'] != null) {
      errorsMap = {};
      (json['errors'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          errorsMap![key] = List<String>.from(value);
        } else if (value is String) {
          errorsMap![key] = [value];
        }
      });
    }

    return AuthResponse(
      message: json['message'] as String?,
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      errors: errorsMap,
    );
  }
}
