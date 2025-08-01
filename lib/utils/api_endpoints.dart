// lib/utils/api_endpoints.dart

class ApiEndpoints {
  static const String baseUrl = 'https://smartstunting.dfxx.site/api';

  // Auth Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';

  // User Endpoints
  static const String userProfile = '$baseUrl/user';

  // Child (Anak) Endpoints
  static const String anak = '$baseUrl/anak';
  static String anakDetail(int id) => '$baseUrl/anak/$id';

  // Antropometry Record Endpoints
  static const String antropometryRecord = '$baseUrl/antropometry-record';
  static String antropometryRecordDetail(int id) =>
      '$baseUrl/antropometry-record/$id';
  static String antropometryRecordByChild(int childId) =>
      '$baseUrl/antropometry-rechild/$childId';

  // Prediction Record Endpoints
  static const String predictionRecord = '$baseUrl/prediction-record';
  static String predictionRecordDetail(int id) =>
      '$baseUrl/prediction-record/$id';
}
