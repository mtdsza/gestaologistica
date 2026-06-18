import 'package:gestao_logistica/domain/entities/veiculo.dart';

abstract class IVeiculoRepository {
  Future<void> insert(Veiculo veiculo);
  Future<void> update(Veiculo veiculo);
  Future<void> delete(Veiculo veiculo);
  Future<List<Veiculo>> findAll();
  Future<Veiculo?> findById(int id);
  // retorna apenas veículos livres
  Future<List<Veiculo>> findAvailable();
}