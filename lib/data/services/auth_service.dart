import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  //Iniciar sesion y guardar token
  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final response = await http.post(
        url,
        body: jsonEncode({
          'correo': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['usuario'];

        //guardar el token y la info del usuario
        await _saveToken(token);
        await _saveUserData(userData);
        return true;
      }

      return false;
    } catch (e) {
      print('Error en el login: $e');
      return false;
    }
  }

  //Guardar Token
  Future<bool> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }

  // Guardar información del usuario
  Future<bool> _saveUserData(dynamic userData) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userDataKey, jsonEncode(userData));
  }

  //Verificar si hay un token guardado
  Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  //Obtener token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener información del usuario
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null && userData.isNotEmpty) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> isDriver() async {
    final userData = await getUserData();
    return userData != null && userData['driver'] == true;
  }

  Future<bool> updateDriverStatus(bool isDriver) async {
    final userData = await getUserData();
    if (userData != null) {
      userData['driver'] = isDriver;
      return _saveUserData(userData);
    }
    return false;
  }

  //Logout
  Future<bool> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    // Eliminar token y datos de usuario
    await prefs.remove(_userDataKey);
    return prefs.remove(_tokenKey);
  }
}