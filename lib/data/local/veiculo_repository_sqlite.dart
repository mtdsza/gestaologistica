import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/veiculo.dart';
import 'package:gestao_logistica/domain/repository/veiculo_repository.dart';

class VeiculoRepositorySqlite implements IVeiculoRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Veiculo veiculo) async {
    final db = await _dbHelper.database;
    await db.insert('veiculos', veiculo.toMap());
  }

  @override
  Future<void> update(Veiculo veiculo) async {
    final db = await _dbHelper.database;
    await db.update(
      'veiculos',
      veiculo.toMap(),
      where: 'id = ?',
      whereArgs: [veiculo.id],
    );
  }

  @override
  Future<void> delete(Veiculo veiculo) async {
    final db = await _dbHelper.database;
    await db.delete(
      'veiculos',
      where: 'id = ?',
      whereArgs: [veiculo.id],
    );
  }

  @override
  Future<List<Veiculo>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('veiculos');
    return list.map((map) => Veiculo.fromMap(map)).toList();
  }

  @override
  Future<Veiculo?> findById(int id) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'veiculos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isNotEmpty) {
      return Veiculo.fromMap(list.first);
    }
    return null;
  }

  @override
  Future<List<Veiculo>> findAvailable() async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'veiculos',
      where: "status = 'Disponivel'",
    );
    return list.map((map) => Veiculo.fromMap(map)).toList();
  }
}