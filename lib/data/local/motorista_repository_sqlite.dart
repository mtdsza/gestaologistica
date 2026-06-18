import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/repository/motorista_repository.dart';

class MotoristaRepositorySqlite implements IMotoristaRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Motorista motorista) async {
    final db = await _dbHelper.database;
    await db.insert('motoristas', motorista.toMap());
  }

  @override
  Future<void> update(Motorista motorista) async {
    final db = await _dbHelper.database;
    await db.update(
      'motoristas',
      motorista.toMap(),
      where: 'id = ?',
      whereArgs: [motorista.id],
    );
  }

  @override
  Future<void> delete(Motorista motorista) async {
    final db = await _dbHelper.database;
    await db.delete(
      'motoristas',
      where: 'id = ?',
      whereArgs: [motorista.id],
    );
  }

  @override
  Future<List<Motorista>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('motoristas');
    return list.map((map) => Motorista.fromMap(map)).toList();
  }

  @override
  Future<Motorista?> findById(int id) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'motoristas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isNotEmpty) {
      return Motorista.fromMap(list.first);
    }
    return null;
  }

  @override
  Future<List<Motorista>> findAvailable() async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'motoristas',
      where: "status = 'Disponivel'",
    );
    return list.map((map) => Motorista.fromMap(map)).toList();
  }
}