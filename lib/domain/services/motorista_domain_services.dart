import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/repository/motorista_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class MotoristaDomainServices {
  final IMotoristaRepository _motoristaRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.motoristaRepository);

  Future<void> insert(Motorista motorista) async {
    await _motoristaRepository.insert(motorista);
  }

  Future<void> update(Motorista motorista) async {
    await _motoristaRepository.update(motorista);
  }

  Future<void> delete(Motorista motorista) async {
    await _motoristaRepository.delete(motorista);
  }

  Future<List<Motorista>> findAll() async {
    return await _motoristaRepository.findAll();
  }

  Future<Motorista?> findById(int id) async {
    return await _motoristaRepository.findById(id);
  }

  Future<List<Motorista>> findAvailable() async {
    return await _motoristaRepository.findAvailable();
  }
}