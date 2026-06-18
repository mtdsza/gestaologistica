import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/transportadora.dart';
import 'package:gestao_logistica/domain/repository/transportadora_repository.dart';

class TransportadoraRepositorySqlite implements ITransportadoraRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Transportadora transportadora) async {
    final db = await _dbHelper.database;
    await db.insert('transportadoras', transportadora.toMap());
  }

  @override
  Future<void> update(Transportadora transportadora) async {
    final db = await _dbHelper.database;
    await db.update(
      'transportadoras',
      transportadora.toMap(),
      where: 'id = ?',
      whereArgs: [transportadora.id],
    );
  }

  @override
  Future<void> delete(Transportadora transportadora) async {
    final db = await _dbHelper.database;
    await db.delete(
      'transportadoras',
      where: 'id = ?',
      whereArgs: [transportadora.id],
    );
  }

  @override
  Future<List<Transportadora>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('transportadoras');
    return list.map((map) => Transportadora.fromMap(map)).toList();
  }

  @override
  Future<Transportadora?> findById(int id) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'transportadoras',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isNotEmpty) {
      return Transportadora.fromMap(list.first);
    }
    return null;
  }
}