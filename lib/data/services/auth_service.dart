import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'jwt_token';

  //Iniciar sesion y guardar token
  Future<bool> login(String email, String password) async {
    try {
      //final url = Uri.parse('http://localhost:8081/auth/login');
      final url = Uri.parse('http://192.168.1.9:8081/auth/login');

      final response = await http.post(
        url,
        body: jsonEncode({
          'correo': email,
          'contraseña': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        return await _saveToken(token);
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

  //Verificar si hay un token guardado
  Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  //Obtener token
  Future <String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  //Logout
  Future<bool> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
  }


}