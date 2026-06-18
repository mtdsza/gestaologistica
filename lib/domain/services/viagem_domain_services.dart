import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/repository/viagem_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class ViagemDomainServices {
  final IViagemRepository _viagemRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.viagemRepository);

  Future<void> insert(Viagem viagem, List<Map<String, dynamic>> itensComQuantidade) async {
    await _viagemRepository.insert(viagem, itensComQuantidade);
  }

  Future<void> updateStatus(int id, String novoStatus) async {
    await _viagemRepository.updateStatus(id, novoStatus);
  }

  Future<void> updateFaturado(int id, bool faturado) async {
    await _viagemRepository.updateFaturado(id, faturado);
  }

  Future<List<Viagem>> findAll() async {
    return await _viagemRepository.findAll();
  }

  Future<Viagem?> findById(int id) async {
    return await _viagemRepository.findById(id);
  }

  Future<List<Viagem>> findByMotorista(int idMotorista) async {
    return await _viagemRepository.findByMotorista(idMotorista);
  }

  Future<List<Map<String, dynamic>>> findItensByViagem(int idViagem) async {
    return await _viagemRepository.findItensByViagem(idViagem);
  }

  Future<double> getFaturamentoTotal() async {
    return await _viagemRepository.getFaturamentoTotal();
  }

  Future<double> getEficienciaNoPrazo() async {
    return await _viagemRepository.getEficienciaNoPrazo();
  }

  Future<int> getViagensEmTransito() async {
    return await _viagemRepository.getViagensEmTransito();
  }

  Future<List<Viagem>> findHistoryByMotorista(int idMotorista) async {
    return await _viagemRepository.findHistoryByMotorista(idMotorista);
  }

  Future<List<Viagem>> findHistoryByVeiculo(int idVeiculo) async {
    return await _viagemRepository.findHistoryByVeiculo(idVeiculo);
  }

  Future<List<Viagem>> findHistoryByTransportadora(int idTransportadora) async {
    return await _viagemRepository.findHistoryByTransportadora(idTransportadora);
  }
}