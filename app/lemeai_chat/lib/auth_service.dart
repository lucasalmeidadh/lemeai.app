// lib/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const _authTokenKey = 'auth_token';

  // Salva o token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  // Pega o token salvo
  Future<String?> getToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Apaga o token (logout)
  Future<void> logout() async {
    await _storage.delete(key: _authTokenKey);
  }

  // Decodifica o token para pegar o ID do usuário (ou outra informação)
  Future<String?> getUserIdFromToken() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // Sua API retorna o ID do usuário na chave 'sub' (subject) do JWT.
      // Se a chave for outra, altere aqui.
      return decodedToken['sub'];
    }
    return null;
  }
}