class Usuario {
  final int id;
  final String nome;
  final String email;
  final String cidade;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cidade,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final endereco = json['address'] as Map<String, dynamic>;

    return Usuario(
      id: json['id'] as int,
      nome: json['name'] as String,
      email: json['email'] as String,
      cidade: endereco['city'] as String,
    );
  }
}