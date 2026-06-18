import 'package:gestao_logistica/domain/entities/transportadora.dart';

abstract class ITransportadoraRepository {
  Future<void> insert(Transportadora transportadora);
  Future<void> update(Transportadora transportadora);
  Future<void> delete(Transportadora transportadora);
  Future<List<Transportadora>> findAll();
  Future<Transportadora?> findById(int id);
}