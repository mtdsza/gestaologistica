import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/usuario.dart';
import 'package:gestao_logistica/domain/repository/usuario_repository.dart';
import 'package:gestao_logistica/core/criptografia_helper.dart';

class UsuarioRepositorySqlite implements IUsuarioRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<Usuario?> login(String username, String password) async {
    final db = await _dbHelper.database;
    final senhaCriptografada = CriptografiaHelper.encriptar(password);

    final list = await db.query(
      'usuarios',
      where: 'username = ? AND password = ? AND ativo = 1',
      whereArgs: [username, senhaCriptografada],
    );

    if (list.isNotEmpty) {
      return Usuario.fromMap(list.first);
    }
    return null;
  }

  @override
  Future<void> insert(Usuario usuario) async {
    final db = await _dbHelper.database;
    final mapaDeDados = usuario.toMap();
    mapaDeDados['password'] = CriptografiaHelper.encriptar(usuario.password);
    await db.insert('usuarios', mapaDeDados);
  }

  @override
  Future<List<Usuario>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('usuarios');
    return list.map((map) => Usuario.fromMap(map)).toList();
  }

  @override
  Future<void> updateAtivo(int id, bool ativo) async {
    final db = await _dbHelper.database;
    await db.update(
      'usuarios',
      {'ativo': ativo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}