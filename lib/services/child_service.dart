// lib/services/child_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stunting_app/models/child.dart';
import 'package:smart_stunting_app/utils/api_endpoints.dart'; // Pastikan path ini benar
import 'package:smart_stunting_app/models/auth_response.dart'; // Pastikan model ini didefinisikan dengan benar

class ChildService {
  // Mengambil token dari SharedPreferences.
  // Pastikan key 'token' digunakan secara konsisten di AuthService juga.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Menggunakan key 'token' sesuai kode Anda
  }

  // Membuat header HTTP dengan Content-Type, Accept, dan Authorization (jika token tersedia).
  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fungsi helper untuk mengurai respons error dari API dan membuat pesan yang lebih detail.
  String _parseErrorResponse(dynamic decodedBody, int statusCode) {
    String errorMessage =
        'Terjadi kesalahan tidak dikenal. (Status: $statusCode)';
    try {
      // Mencoba mengurai respons sebagai AuthResponse
      final authResponse = AuthResponse.fromJson(decodedBody);
      errorMessage = authResponse.message ?? errorMessage;
      if (authResponse.errors != null && authResponse.errors!.isNotEmpty) {
        authResponse.errors!.forEach((key, value) {
          errorMessage += '\n- ${value.join(', ')}';
        });
      }
    } catch (e) {
      // Jika gagal mengurai sebagai AuthResponse, gunakan pesan error generik
      // dan sertakan body respons mentah untuk debugging.
      errorMessage =
          'Kesalahan API (Status: $statusCode): ${decodedBody.toString()}';
    }
    return errorMessage;
  }

  // --- GET All Children ---
  /// Mengambil daftar semua anak yang terkait dengan pengguna terautentikasi.
  /// Menangani respons API yang mungkin berupa list langsung, "No data found",
  /// atau di dalam wrapper 'data'.
  Future<List<Child>> fetchChildren() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.anak); // Menggunakan ApiEndpoints
    http.Response response;

    try {
      response = await http.get(url, headers: _getHeaders(token));

      print('--- FETCH CHILDREN API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      try {
        if (response.body.isNotEmpty) {
          // Pastikan body tidak kosong sebelum decode
          decodedBody = json.decode(response.body);
        } else {
          // Jika body kosong tapi status 200, anggap sebagai daftar kosong.
          if (response.statusCode == 200) return [];
          throw Exception('Respons API kosong.');
        }
      } catch (e) {
        throw Exception(
          'Gagal parse JSON respons dari API. Respons bukan JSON valid: $e. Body: ${response.body}',
        );
      }

      if (response.statusCode == 200) {
        if (decodedBody is Map<String, dynamic> &&
            decodedBody['message'] == 'No data found') {
          print('API mengembalikan "No data found". Menganggap daftar kosong.');
          return [];
        } else if (decodedBody is List) {
          // Jika respons langsung berupa List of children
          return decodedBody.map((data) => Child.fromJson(data)).toList();
        } else if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('data') &&
            decodedBody['data'] is List) {
          // Jika respons dibungkus dalam key 'data'
          return (decodedBody['data'] as List)
              .map((data) => Child.fromJson(data))
              .toList();
        } else {
          throw Exception(
            'Format data anak tidak valid. Respons tidak berupa list, wrapper "data", atau "No data found". Body: ${response.body}',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error fetching children (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow; // Melemparkan kembali pengecualian untuk ditangani oleh UI
    }
  }

  // --- GET Single Child ---
  /// Mengambil detail satu anak berdasarkan ID.
  Future<Child> fetchChild(int childId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.anakDetail(childId),
    ); // Menggunakan ApiEndpoints
    http.Response response;

    try {
      response = await http.get(url, headers: _getHeaders(token));

      print('--- FETCH SINGLE CHILD API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      try {
        if (response.body.isNotEmpty) {
          decodedBody = json.decode(response.body);
        } else {
          throw Exception('Respons API kosong saat mengambil detail anak.');
        }
      } catch (e) {
        throw Exception(
          'Gagal parse JSON respons detail anak: $e. Body: ${response.body}',
        );
      }

      if (response.statusCode == 200) {
        if (decodedBody is Map<String, dynamic>) {
          return Child.fromJson(decodedBody);
        } else {
          throw Exception(
            'Format data detail anak tidak valid. Respons bukan objek tunggal.',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error fetching child detail (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- ADD New Child ---
  /// Menambahkan data anak baru ke API.
  /// Mengembalikan objek Child yang dibuat jika berhasil.
  Future<Child> addChild(Child child) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(ApiEndpoints.anak); // Menggunakan ApiEndpoints
    http.Response response;

    try {
      final Map<String, dynamic> requestBody = child.toJson();
      response = await http.post(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- ADD CHILD API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      try {
        if (response.body.isNotEmpty) {
          decodedBody = json.decode(response.body);
        } else {
          // Jika body kosong tapi status 201, berarti berhasil dibuat tanpa body
          if (response.statusCode == 201) {
            // Kita bisa mengembalikan Child yang dikirim jika API tidak mengembalikan apa-apa
            // atau jika API mengembalikan ID, kita bisa tambahkan ID ke objek Child.
            // Untuk skenario ini, kita akan asumsikan API mengembalikan objek Child lengkap.
            throw Exception('Respons API kosong saat menambah anak.');
          }
          throw Exception('Respons API kosong.');
        }
      } catch (e) {
        throw Exception(
          'Gagal parse JSON respons tambah anak: $e. Body: ${response.body}',
        );
      }

      if (response.statusCode == 201) {
        if (decodedBody is Map<String, dynamic>) {
          return Child.fromJson(decodedBody);
        } else {
          throw Exception(
            'Format respons sukses tambah anak tidak valid. Diharapkan objek Child. Body: ${response.body}',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error adding child (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- UPDATE Child ---
  /// Memperbarui data anak yang sudah ada.
  /// Mengembalikan objek Child yang diperbarui jika berhasil.
  Future<Child> updateChild(Child child) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    if (child.id == null) {
      throw Exception('ID Anak tidak boleh null untuk pembaruan.');
    }

    final url = Uri.parse(
      ApiEndpoints.anakDetail(child.id!),
    ); // Menggunakan ApiEndpoints
    http.Response response;

    try {
      final Map<String, dynamic> requestBody = child.toJson();
      response = await http.put(
        url,
        headers: _getHeaders(token),
        body: json.encode(requestBody),
      );

      print('--- UPDATE CHILD API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      try {
        if (response.body.isNotEmpty) {
          decodedBody = json.decode(response.body);
        } else {
          throw Exception('Respons API kosong saat memperbarui anak.');
        }
      } catch (e) {
        throw Exception(
          'Gagal parse JSON respons update anak: $e. Body: ${response.body}',
        );
      }

      // Asumsi API mengembalikan objek Child yang diperbarui pada sukses (200 OK)
      if (response.statusCode == 200) {
        if (decodedBody is Map<String, dynamic>) {
          return Child.fromJson(decodedBody);
        } else {
          throw Exception(
            'Format respons sukses update anak tidak valid. Diharapkan objek Child. Body: ${response.body}',
          );
        }
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error updating child (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }

  // --- DELETE Child ---
  /// Menghapus data anak berdasarkan ID.
  /// Mengembalikan AuthResponse yang berisi pesan konfirmasi.
  Future<AuthResponse> deleteChild(int childId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.anakDetail(childId),
    ); // Menggunakan ApiEndpoints
    http.Response response;

    try {
      response = await http.delete(url, headers: _getHeaders(token));

      print('--- DELETE CHILD API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------------');

      dynamic decodedBody;
      try {
        // Jika body kosong (misalnya 204 No Content), json.decode akan gagal.
        // Tangani ini dengan baik untuk operasi delete.
        if (response.body.isEmpty) {
          if (response.statusCode == 200 || response.statusCode == 204) {
            return AuthResponse(message: "Anak berhasil dihapus", errors: {});
          }
        }
        decodedBody = json.decode(response.body);
      } catch (e) {
        throw Exception(
          'Gagal parse JSON respons hapus anak: $e. Body: ${response.body}',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Mencoba mengurai AuthResponse dari body jika ada.
        return AuthResponse.fromJson(decodedBody);
      } else {
        throw Exception(_parseErrorResponse(decodedBody, response.statusCode));
      }
    } catch (e) {
      print('Error deleting child (final catch block): $e');
      if (e is http.ClientException) {
        throw Exception('Koneksi jaringan bermasalah: ${e.message}');
      }
      rethrow;
    }
  }
}
