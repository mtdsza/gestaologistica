import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/item_inventario.dart';
import 'package:gestao_logistica/domain/repository/item_inventario_repository.dart';

class ItemInventarioRepositorySqlite implements IItemInventarioRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(ItemInventario item) async {
    final db = await _dbHelper.database;
    await db.insert('itens_inventario', item.toMap());
  }

  @override
  Future<void> update(ItemInventario item) async {
    final db = await _dbHelper.database;
    await db.update(
      'itens_inventario',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> delete(ItemInventario item) async {
    final db = await _dbHelper.database;
    await db.delete(
      'itens_inventario',
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<List<ItemInventario>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('itens_inventario');
    return list.map((map) => ItemInventario.fromMap(map)).toList();
  }

  @override
  Future<ItemInventario?> findById(int id) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'itens_inventario',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (list.isNotEmpty) {
      return ItemInventario.fromMap(list.first);
    }
    return null;
  }

  @override
  Future<void> updateStock(int id, int novaQuantidade) async {
    final db = await _dbHelper.database;
    await db.update(
      'itens_inventario',
      {'quantidade': novaQuantidade},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}