import 'package:flutter/material.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  final String cidade;
  final String? telefone;
  final String? website;
  
  // Cores únicas baseadas no nome
  late final Color corPrincipal;
  late final Color corSecundaria;
  
  // Ícone personalizado
  late final IconData iconePersonalizado;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cidade,
    this.telefone,
    this.website,
  }) {
    _gerarCoresUnicas();
    _definirIconePersonalizado();
  }

  void _gerarCoresUnicas() {
    final List<Color> coresNeon = [
      const Color(0xFF00F5FF), // Ciano Neon
      const Color(0xFF00FF88), // Verde Neon
      const Color(0xFFFF006E), // Rosa Neon
      const Color(0xFFB200FF), // Roxo Neon
      const Color(0xFFFFB300), // Amarelo Neon
      const Color(0xFFFF3B00), // Laranja Neon
      const Color(0xFF00D4FF), // Azul Claro Neon
      const Color(0xFF9D00FF), // Violeta Neon
    ];
    
    final int index = nome.hashCode.abs() % coresNeon.length;
    corPrincipal = coresNeon[index];
    corSecundaria = coresNeon[(index + 1) % coresNeon.length];
  }

  void _definirIconePersonalizado() {
    // TODOS estes ícones EXISTEM no Flutter
    final Map<String, IconData> iconesMap = {
      'A': Icons.abc,
      'B': Icons.bolt,
      'C': Icons.cake,
      'D': Icons.diamond,
      'E': Icons.email,
      'F': Icons.face,
      'G': Icons.gamepad,
      'H': Icons.home,
      'I': Icons.info,
      'J': Icons.javascript,      // ✅ Existe!
      'K': Icons.key,
      'L': Icons.language,
      'M': Icons.music_note,
      'N': Icons.nature,
      'O': Icons.adjust,           // ✅ Substituído 'oval' por 'adjust'
      'P': Icons.person,
      'Q': Icons.question_answer,
      'R': Icons.rocket,
      'S': Icons.star,
      'T': Icons.telegram,
      'U': Icons.umbrella,
      'V': Icons.videogame_asset,
      'W': Icons.wifi,
      'X': Icons.close,
      'Y': Icons.yard,
      'Z': Icons.zoom_in,
    };
    
    final primeiraLetra = nome.isNotEmpty ? nome[0].toUpperCase() : 'A';
    iconePersonalizado = iconesMap[primeiraLetra] ?? Icons.person;
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final endereco = json['address'] as Map<String, dynamic>? ?? {};

    return Usuario(
      id: json['id'] as int? ?? 0,
      nome: json['name'] as String? ?? 'Herói Sem Nome',
      email: json['email'] as String? ?? 'sem@email.com',
      cidade: endereco['city'] as String? ?? 'Cidade Misteriosa',
      telefone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'phone': telefone,
      'website': website,
      'address': {'city': cidade},
    };
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? cidade,
    String? telefone,
    String? website,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cidade: cidade ?? this.cidade,
      telefone: telefone ?? this.telefone,
      website: website ?? this.website,
    );
  }

  // Nova função: Iniciais do nome
  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, 2).toUpperCase();
  }

  // Nova função: Email mascarado para privacidade
  String get emailMascarado {
    final partes = email.split('@');
    if (partes[0].length > 4) {
      return '${partes[0].substring(0, 4)}***@${partes[1]}';
    }
    return email;
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, email: $email, cidade: $cidade)';
  }
}