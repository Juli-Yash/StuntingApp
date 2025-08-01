// lib/services/antropometry_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stunting_app/models/antropometry_record.dart';
import 'package:smart_stunting_app/utils/api_endpoints.dart';
import 'package:smart_stunting_app/models/auth_response.dart';

class AntropometryService {
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
        // Coba parse sebagai AuthResponse untuk mendapatkan pesan/error lebih detail
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

  // --- GET All Antropometry Records for Authenticated User ---
  Future<List<AntropometryRecord>> fetchAntropometryRecords() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.antropometryRecord);
    try {
      final response = await http.get(url, headers: _getHeaders(token));

      print('--- FETCH ANTROPOMETRY RECORDS API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode == 200) {
        // PERBAIKAN DI SINI:
        // Jika API mengembalikan array langsung (e.g., []), bukan {"data": []}
        if (decodedBody is List) {
          return decodedBody
              .map((data) => AntropometryRecord.fromJson(data))
              .toList();
        } else if (decodedBody != null &&
            decodedBody is Map<String, dynamic> &&
            decodedBody['data'] is List) {
          return (decodedBody['data'] as List)
              .map((data) => AntropometryRecord.fromJson(data))
              .toList();
        } else {
          throw Exception(
            'Format data riwayat antropometri tidak valid: ${response.body}',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error fetching antropometry records: $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- ADD New Antropometry Record ---
  // Akan mengembalikan langsung AntropometryRecord saat sukses
  Future<AntropometryRecord> createAntropometryRecord(
    AntropometryRecord record,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.antropometryRecord);
    http.Response response;

    try {
      final Map<String, dynamic> requestBody = record.toJson();
      response = await http.post(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- ADD ANTROPOMETRY API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Jika sukses, kita harapkan body adalah AntropometryRecord yang baru dibuat
        if (decodedBody != null && decodedBody is Map<String, dynamic>) {
          return AntropometryRecord.fromJson(decodedBody);
        } else {
          throw Exception(
            'Respons sukses, namun format data antropometri tidak valid.',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error adding antropometry record (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- UPDATE Antropometry Record ---
  // Akan mengembalikan langsung AntropometryRecord saat sukses
  Future<AntropometryRecord> updateAntropometryRecord(
    AntropometryRecord record,
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    if (record.id == null) {
      throw Exception(
        'ID Antropometry Record tidak boleh null untuk pembaruan.',
      );
    }

    final url = Uri.parse(ApiEndpoints.antropometryRecordDetail(record.id!));
    http.Response response;

    try {
      final Map<String, dynamic> requestBody = record.toJson();
      response = await http.put(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- UPDATE ANTROPOMETRY API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('--------------------------------------');

      dynamic decodedBody;
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Jika sukses, kita harapkan body adalah AntropometryRecord yang diperbarui
        if (decodedBody != null && decodedBody is Map<String, dynamic>) {
          return AntropometryRecord.fromJson(decodedBody);
        } else {
          throw Exception(
            'Respons sukses, namun format data antropometri tidak valid.',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error updating antropometry record (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- DELETE Antropometry Record ---
  // Mengembalikan AuthResponse karena biasanya hanya ada pesan sukses/error
  Future<AuthResponse> deleteAntropometryRecord(int recordId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.antropometryRecordDetail(recordId));
    http.Response response;

    try {
      response = await http.delete(url, headers: _getHeaders(token));

      print('--- DELETE ANTROPOMETRY API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('--------------------------------------');

      dynamic decodedBody;
      // Perhatikan: respons DELETE (204 No Content) mungkin tidak memiliki body
      if (response.body.isNotEmpty) {
        decodedBody = json.decode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204) {
          // 204 No Content berarti sukses tanpa body. Berikan AuthResponse default.
          return AuthResponse(
            message: "Data antropometri berhasil dihapus.",
            errors: {},
          );
        }
        // Untuk 200 OK dengan body, coba parse sebagai AuthResponse
        if (decodedBody != null && decodedBody is Map<String, dynamic>) {
          return AuthResponse.fromJson(decodedBody);
        } else {
          // Jika 200 OK tapi body tidak sesuai AuthResponse, berikan pesan sukses default.
          return AuthResponse(
            message: "Data antropometri berhasil dihapus.",
            errors: {},
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error deleting antropometry record (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }
}
