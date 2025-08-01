// lib/services/prediction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stunting_app/models/prediction_record.dart';
import 'package:smart_stunting_app/utils/api_endpoints.dart';
import 'package:smart_stunting_app/models/auth_response.dart'; // Asumsi Anda punya AuthResponse

class PredictionService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _parseErrorResponse(dynamic decodedBody, int statusCode) {
    String errorMessage =
        'Terjadi kesalahan tidak dikenal. (Status: $statusCode)';
    try {
      if (decodedBody is Map<String, dynamic>) {
        final authResponse = AuthResponse.fromJson(decodedBody);
        errorMessage = authResponse.message ?? errorMessage;
        if (authResponse.errors != null && authResponse.errors!.isNotEmpty) {
          authResponse.errors!.forEach((key, value) {
            errorMessage += '\n- ${value.join(', ')}';
          });
        }
      } else {
        errorMessage =
            'Kesalahan API (Status: $statusCode): ${decodedBody?.toString() ?? 'Respons kosong'}';
      }
    } catch (e) {
      errorMessage =
          'Kesalahan parsing error API (Status: $statusCode): $e. Body: ${decodedBody?.toString() ?? 'kosong'}';
    }
    return errorMessage;
  }

  // --- GET All Prediction Records for Authenticated User ---
  Future<List<PredictionRecord>> fetchPredictionRecords() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.predictionRecord,
    ); // Asumsi Anda punya ApiEndpoints.predictionRecord
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      print('--- FETCH PREDICTION RECORDS API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode == 200) {
        if (decodedBody != null && decodedBody['data'] is List) {
          return (decodedBody['data'] as List)
              .map((data) => PredictionRecord.fromJson(data))
              .toList();
        } else {
          throw Exception('Format data riwayat prediksi tidak valid.');
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error fetching prediction records: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- GET Prediction Record by ID ---
  Future<PredictionRecord> getPredictionRecordById(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.predictionRecordDetail(id),
    ); // Asumsi Anda punya ApiEndpoints.predictionRecordDetail
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      print('--- GET SINGLE PREDICTION RECORD API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode == 200) {
        if (decodedBody != null &&
            decodedBody['data'] is Map<String, dynamic>) {
          return PredictionRecord.fromJson(decodedBody['data']);
        } else {
          throw Exception('Format data prediksi tidak valid.');
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error getting single prediction record: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- CREATE Prediction Record ---
  Future<PredictionRecord> createPredictionRecord(
    PredictionRecord record,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.predictionRecord);
    try {
      final Map<String, dynamic> requestBody = record.toJson();
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- CREATE PREDICTION RECORD API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decodedBody != null &&
            decodedBody['data'] is Map<String, dynamic>) {
          return PredictionRecord.fromJson(decodedBody['data']);
        } else {
          throw Exception('Format respons pembuatan prediksi tidak valid.');
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error creating prediction record: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- UPDATE Prediction Record ---
  Future<PredictionRecord> updatePredictionRecord(
    PredictionRecord record,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }
    if (record.id == null) {
      throw Exception('ID Prediction Record tidak boleh null untuk pembaruan.');
    }

    final url = Uri.parse(ApiEndpoints.predictionRecordDetail(record.id!));
    try {
      final Map<String, dynamic> requestBody = record.toJson();
      final response = await http.put(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- UPDATE PREDICTION RECORD API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decodedBody != null &&
            decodedBody['data'] is Map<String, dynamic>) {
          return PredictionRecord.fromJson(decodedBody['data']);
        } else {
          throw Exception('Format respons pembaruan prediksi tidak valid.');
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error updating prediction record: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- DELETE Prediction Record ---
  Future<AuthResponse> deletePredictionRecord(int id) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.predictionRecordDetail(id));
    try {
      final response = await http.delete(url, headers: _getHeaders(token));

      print('--- DELETE PREDICTION RECORD API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204) {
          return AuthResponse(
            message: "Prediksi berhasil dihapus.",
            errors: {},
          );
        }
        if (decodedBody != null && decodedBody is Map<String, dynamic>) {
          return AuthResponse.fromJson(decodedBody);
        } else {
          return AuthResponse(
            message: "Prediksi berhasil dihapus.",
            errors: {},
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error deleting prediction record: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }
}
