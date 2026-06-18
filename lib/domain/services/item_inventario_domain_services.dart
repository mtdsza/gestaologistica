import 'package:gestao_logistica/domain/entities/item_inventario.dart';
import 'package:gestao_logistica/domain/repository/item_inventario_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class ItemInventarioDomainServices {
  final IItemInventarioRepository _itemInventarioRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.itemInventarioRepository);

  Future<void> insert(ItemInventario item) async {
    await _itemInventarioRepository.insert(item);
  }

  Future<void> update(ItemInventario item) async {
    await _itemInventarioRepository.update(item);
  }

  Future<void> delete(ItemInventario item) async {
    await _itemInventarioRepository.delete(item);
  }

  Future<List<ItemInventario>> findAll() async {
    return await _itemInventarioRepository.findAll();
  }

  Future<ItemInventario?> findById(int id) async {
    return await _itemInventarioRepository.findById(id);
  }

  Future<void> updateStock(int id, int novaQuantidade) async {
    await _itemInventarioRepository.updateStock(id, novaQuantidade);
  }
}