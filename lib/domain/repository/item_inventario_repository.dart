import 'package:gestao_logistica/domain/entities/item_inventario.dart';

abstract class IItemInventarioRepository {
  Future<void> insert(ItemInventario item);
  Future<void> update(ItemInventario item);
  Future<void> delete(ItemInventario item);
  Future<List<ItemInventario>> findAll();
  Future<ItemInventario?> findById(int id);
  // atualiza a quantidade
  Future<void> updateStock(int id, int novaQuantidade);
}