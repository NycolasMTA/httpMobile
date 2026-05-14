import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _usersEndpoint = '/users';
  
  // Cache e Controle
  static List<Usuario>? _cache;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);
  static int _requisicoesCount = 0;
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Buscar todos com cache inteligente
  static Future<List<Usuario>> buscarUsuarios({
    bool forceRefresh = false,
    bool usarCache = true,
  }) async {
    _requisicoesCount++;
    
    // Usar cache se disponível e válido
    if (!forceRefresh && usarCache && _cache != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cache!;
      }
    }
    
    try {
      final uri = Uri.parse('$_baseUrl$_usersEndpoint');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('🌐 Conexão lenta, tente novamente!'),
      );

      if (response.statusCode == 200) {
        final listaJson = jsonDecode(response.body) as List<dynamic>;
        final usuarios = listaJson
            .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Atualizar cache
        _cache = usuarios;
        _cacheTime = DateTime.now();
        
        return usuarios;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('⚡ Erro explosivo: $e');
    }
  }

  // Buscar com paginação (nova função)
  static Future<List<Usuario>> buscarUsuariosPaginados({int page = 1, int limit = 5}) async {
    final todos = await buscarUsuarios(forceRefresh: true);
    final inicio = (page - 1) * limit;
    final fim = inicio + limit;
    return todos.skip(inicio).take(limit).toList();
  }

  // Buscar por nome (nova função)
  static Future<List<Usuario>> buscarPorNome(String termo) async {
    final todos = await buscarUsuarios();
    return todos.where((u) => 
      u.nome.toLowerCase().contains(termo.toLowerCase())
    ).toList();
  }

  static Future<Usuario> criarUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_usersEndpoint'),
        headers: _headers,
        body: jsonEncode(usuario.toJson()),
      );

      if (response.statusCode == 201) {
        final novoUsuario = Usuario.fromJson(jsonDecode(response.body));
        _cache = null; // Invalidar cache
        return novoUsuario;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('🚀 Falha na criação: $e');
    }
  }

  static Future<Usuario> atualizarUsuario(Usuario usuario) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_usersEndpoint/${usuario.id}'),
        headers: _headers,
        body: jsonEncode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        final usuarioAtualizado = Usuario.fromJson(jsonDecode(response.body));
        _cache = null;
        return usuarioAtualizado;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('✏️ Erro na atualização: $e');
    }
  }

  static Future<bool> deletarUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_usersEndpoint/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _cache = null;
        return true;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('🗑️ Erro na exclusão: $e');
    }
  }

  // Estatísticas da API
  static int get totalRequisicoes => _requisicoesCount;
  
  static void limparCache() {
    _cache = null;
    _cacheTime = null;
  }

  static String _handleError(http.Response response) {
    final Map<int, String> errors = {
      400: '📝 Requisição inválida',
      401: '🔒 Precisa de autenticação',
      403: '🚫 Acesso negado',
      404: '🔍 Usuário não encontrado',
      500: '💥 Erro no servidor',
    };
    return errors[response.statusCode] ?? '❌ Erro ${response.statusCode}';
  }
}