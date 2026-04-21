import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'token_storage.dart';

class ApiService {
  // URL base del servicio externo
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }
  
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Registrar un nuevo usuario
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      // Status and Body check removed for production

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar token
        if (data['token'] != null) {
          await TokenStorage.saveToken(data['token']);
        }
        if (data['user'] != null) {
          await TokenStorage.saveUser(data['user']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      // Handle error without printing for production
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Iniciar sesión
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar token
        if (data['token'] != null) {
          await TokenStorage.saveToken(data['token']);
        }
        if (data['user'] != null) {
          await TokenStorage.saveUser(data['user']);
        }

        return {
          'success': true,
          'message': 'Login exitoso',
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales inválidas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Cerrar sesión
  Future<bool> logoutUser() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      await TokenStorage.clear();
      return response.statusCode == 200;
    } catch (e) {
      // Clear local anyway
      await TokenStorage.clear();
      return false;
    }
  }

  // Verificar token
  Future<bool> verifyToken() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ================== RUTAS DEL GEMELO DIGITAL ==================

  // Sincronizar transacciones guardadas localmente hacia el backend MySQL
  Future<Map<String, dynamic>> syncTransactions(List<Map<String, dynamic>> transactions) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return {'success': false, 'message': 'No hay sesión activa para sincronizar'};

      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transacciones': transactions
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Sincronizado correctamente'};
      } else {
        return {'success': false, 'message': 'Error del servidor al sincronizar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Descargar el resumen y estado de las alertas (Metas vs Gastos)
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return {'success': false, 'message': 'Token no encontrado'};

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/reports/monthly?year=$year&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'gastosTotales': data['gastosTotales'] ?? 0.0,
          'alertaCritica': data['alertaCritica'] ?? false,
        };
      } else {
        return {'success': false, 'message': 'Fallo obteniendo reporte'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
