import 'package:gestao_logistica/domain/entities/viagem.dart';

abstract class IViagemRepository {
  Future<void> insert(Viagem viagem, List<Map<String, dynamic>> itensComQuantidade);
  Future<void> updateStatus(int id, String novoStatus);
  Future<void> updateFaturado(int id, bool faturado);
  Future<List<Viagem>> findAll();
  Future<Viagem?> findById(int id);
  Future<List<Viagem>> findByMotorista(int idMotorista);
  Future<List<Map<String, dynamic>>> findItensByViagem(int idViagem);
  Future<double> getFaturamentoTotal();
  Future<double> getEficienciaNoPrazo();
  Future<int> getViagensEmTransito();
  
  Future<List<Viagem>> findHistoryByMotorista(int idMotorista);
  Future<List<Viagem>> findHistoryByVeiculo(int idVeiculo);
  Future<List<Viagem>> findHistoryByTransportadora(int idTransportadora);
}