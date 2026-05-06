import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Usuario>> buscarUsuarios() async {
    final uri = Uri.parse('$_baseUrl/users');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar usuarios: ${response.statusCode}');
    }

    final listaJson = jsonDecode(response.body) as List<dynamic>;

    return listaJson
        .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}