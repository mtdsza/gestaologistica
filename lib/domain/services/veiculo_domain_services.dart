import 'package:gestao_logistica/domain/entities/veiculo.dart';
import 'package:gestao_logistica/domain/repository/veiculo_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class VeiculoDomainServices {
  final IVeiculoRepository _veiculoRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.veiculoRepository);

  Future<void> insert(Veiculo veiculo) async {
    await _veiculoRepository.insert(veiculo);
  }

  Future<void> update(Veiculo veiculo) async {
    await _veiculoRepository.update(veiculo);
  }

  Future<void> delete(Veiculo veiculo) async {
    await _veiculoRepository.delete(veiculo);
  }

  Future<List<Veiculo>> findAll() async {
    return await _veiculoRepository.findAll();
  }

  Future<Veiculo?> findById(int id) async {
    return await _veiculoRepository.findById(id);
  }

  Future<List<Veiculo>> findAvailable() async {
    return await _veiculoRepository.findAvailable();
  }

  
}