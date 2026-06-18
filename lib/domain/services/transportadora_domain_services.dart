import 'package:gestao_logistica/domain/entities/transportadora.dart';
import 'package:gestao_logistica/domain/repository/transportadora_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class TransportadoraDomainServices {
  final ITransportadoraRepository _transportadoraRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.transportadoraRepository);

  Future<void> insert(Transportadora transportadora) async {
    await _transportadoraRepository.insert(transportadora);
  }

  Future<void> update(Transportadora transportadora) async {
    await _transportadoraRepository.update(transportadora);
  }

  Future<void> delete(Transportadora transportadora) async {
    await _transportadoraRepository.delete(transportadora);
  }

  Future<List<Transportadora>> findAll() async {
    return await _transportadoraRepository.findAll();
  }

  Future<Transportadora?> findById(int id) async {
    return await _transportadoraRepository.findById(id);
  }
}