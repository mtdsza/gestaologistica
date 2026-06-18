import 'package:gestao_logistica/domain/entities/motorista.dart';

abstract class IMotoristaRepository {
  Future<void> insert(Motorista motorista);
  Future<void> update(Motorista motorista);
  Future<void> delete(Motorista motorista);
  Future<List<Motorista>> findAll();
  Future<Motorista?> findById(int id);
  // retorna apenas motoristas livres
  Future<List<Motorista>> findAvailable();
}