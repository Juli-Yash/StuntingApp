// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stunting_app/models/user.dart';
import 'package:smart_stunting_app/models/auth_response.dart';
import 'package:smart_stunting_app/utils/api_endpoints.dart'; // Pastikan file ini ada dan berisi URL yang benar

class AuthService {
  // Mengubah _getToken menjadi public getToken
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Map<String, String> _getHeaders({String? token, bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Register ---
  Future<AuthResponse> register(
    String name,
    String phone,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse(
      ApiEndpoints.register,
    ); // Pastikan ApiEndpoints.register itu benar
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'name': name,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- DEBUG PRINTS UNTUK REGISTER ---
      print('--- REGISTER API RESPONSE ---');
      print('Request URL: $url');
      print(
        'Request Body: ${json.encode({'name': name, 'phone': phone, 'password': password, 'password_confirmation': passwordConfirmation})}',
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-----------------------------');
      // --- END DEBUG PRINTS ---

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token =
            responseBody['access_token']; // Pastikan nama key 'access_token' sesuai API
        if (token != null) {
          await _setToken(token);
        }
        return AuthResponse.fromJson(responseBody);
      } else {
        // Jika status code bukan 200/201, tetap coba parse responseBody
        // agar pesan error dari server bisa ditampilkan
        return AuthResponse.fromJson(responseBody);
      }
    } catch (e) {
      print('Error during registration (catch block): $e');
      return AuthResponse(
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
      );
    }
  }

  // --- Login ---
  Future<AuthResponse> login(String phone, String password) async {
    final url = Uri.parse(
      ApiEndpoints.login,
    ); // Pastikan ApiEndpoints.login itu benar
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({'phone': phone, 'password': password}),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- DEBUG PRINTS UNTUK LOGIN ---
      print('--- LOGIN API RESPONSE ---');
      print('Request URL: $url');
      print(
        'Request Body: ${json.encode({'phone': phone, 'password': password})}',
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('--------------------------');
      // --- END DEBUG PRINTS ---

      if (response.statusCode == 200) {
        final token =
            responseBody['access_token']; // Pastikan nama key 'access_token' sesuai API
        if (token != null) {
          await _setToken(token);
        }
        return AuthResponse.fromJson(responseBody);
      } else {
        // Jika status code bukan 200, tetap coba parse responseBody
        // agar pesan error dari server bisa ditampilkan
        return AuthResponse.fromJson(responseBody);
      }
    } catch (e) {
      print('Error during login (catch block): $e');
      return AuthResponse(
        message: 'Terjadi kesalahan jaringan: ${e.toString()}',
      );
    }
  }

  // --- Logout ---
  Future<AuthResponse> logout() async {
    final token = await getToken();
    if (token == null) {
      return AuthResponse(message: 'Tidak ada token, sudah logout.');
    }

    final url = Uri.parse(
      ApiEndpoints.logout,
    ); // Pastikan ApiEndpoints.logout itu benar
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token: token, includeAuth: true),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- DEBUG PRINTS UNTUK LOGOUT ---
      print('--- LOGOUT API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('---------------------------');
      // --- END DEBUG PRINTS ---

      if (response.statusCode == 200) {
        await _clearToken();
        return AuthResponse.fromJson(responseBody);
      } else {
        await _clearToken();
        return AuthResponse.fromJson(responseBody);
      }
    } catch (e) {
      print('Error during logout (catch block): $e');
      await _clearToken();
      return AuthResponse(
        message:
            'Terjadi kesalahan jaringan saat mencoba logout: ${e.toString()}',
      );
    }
  }

  // --- Get User Profile ---
  Future<User> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.userProfile,
    ); // Pastikan ApiEndpoints.userProfile itu benar
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(token: token, includeAuth: true),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- DEBUG PRINTS UNTUK GET USER PROFILE ---
      print('--- GET USER PROFILE API RESPONSE ---');
      print('Request URL: $url');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-------------------------------------');
      // --- END DEBUG PRINTS ---

      if (response.statusCode == 200) {
        return User.fromJson(responseBody);
      } else if (response.statusCode == 401) {
        await _clearToken();
        throw Exception(
          'Unauthorized: Sesi Anda telah berakhir. Silakan login ulang.',
        );
      } else {
        // Coba parsing sebagai AuthResponse untuk pesan error yang lebih detail
        final authResponse = AuthResponse.fromJson(responseBody);
        String errorMessage = authResponse.message ?? 'Gagal memuat profil.';
        if (authResponse.errors != null) {
          authResponse.errors!.forEach((key, value) {
            errorMessage += '\n${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error fetching user profile (catch block): $e');
      rethrow;
    }
  }

  // --- Update User Profile ---
  // MENGUBAH TIPE KEMBALIAN DARI AuthResponse MENJADI User
  Future<User> updateUserProfile(
    // <--- PERUBAHAN DI SINI
    String name,
    String phone,
    String? email,
    String? password,
    String? passwordConfirmation,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Sesi berakhir. Mohon login kembali.');
    }

    final url = Uri.parse(
      ApiEndpoints.userProfile,
    ); // Pastikan ApiEndpoints.userProfile itu benar
    final Map<String, dynamic> body = {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (passwordConfirmation != null && passwordConfirmation.isNotEmpty)
        'password_confirmation': passwordConfirmation,
    };

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(token: token, includeAuth: true),
        body: json.encode(body),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // --- DEBUG PRINTS UNTUK UPDATE USER PROFILE ---
      print('--- UPDATE USER PROFILE API RESPONSE ---');
      print('Request URL: $url');
      print('Request Body: ${json.encode(body)}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('----------------------------------------');
      // --- END DEBUG PRINTS ---

      if (response.statusCode == 200) {
        // JIKA SUKSES (STATUS 200), KEMBALIKAN OBJEK USER
        return User.fromJson(responseBody); // <--- PERUBAHAN DI SINI
      } else if (response.statusCode == 401) {
        await _clearToken();
        throw Exception(
          'Unauthorized: Sesi Anda telah berakhir. Silakan login ulang untuk update profil.',
        );
      } else {
        // JIKA ADA ERROR (STATUS BUKAN 200, 401), COBA PARSE SEBAGAI AUTHRESPONSE UNTUK DETAIL ERROR
        final authResponse = AuthResponse.fromJson(responseBody);
        String errorMessage =
            authResponse.message ?? 'Gagal memperbarui profil.';
        if (authResponse.errors != null) {
          authResponse.errors!.forEach((key, value) {
            errorMessage += '\n${value.join(', ')}';
          });
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error updating user profile (catch block): $e');
      rethrow; // Re-throw the exception so it can be caught in the UI layer
    }
  }
}
