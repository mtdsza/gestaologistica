class Usuario {
  final int? id;
  final String username;
  final String password;
  final bool isAdmin;
  final int? idMotorista;
  final bool ativo;

  Usuario({
    this.id,
    required this.username,
    required this.password,
    required this.isAdmin,
    this.idMotorista,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'is_admin': isAdmin ? 1 : 0,
      'id_motorista': idMotorista,
      'ativo': ativo ? 1 : 0,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      isAdmin: (map['is_admin'] as int) == 1,
      idMotorista: map['id_motorista'] as int?,
      ativo: map['ativo'] == null ? true : (map['ativo'] as int) == 1,
    );
  }
}