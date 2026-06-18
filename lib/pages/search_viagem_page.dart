import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';
import 'package:gestao_logistica/domain/services/veiculo_domain_services.dart';
import 'package:gestao_logistica/domain/services/transportadora_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

class SearchViagemPage extends StatefulWidget {
  const SearchViagemPage({super.key});

  @override
  State<SearchViagemPage> createState() => _SearchViagemPageState();
}

class _SearchViagemPageState extends State<SearchViagemPage> {
  final _viagemServices = ViagemDomainServices();
  final _motoristaServices = MotoristaDomainServices();
  final _veiculoServices = VeiculoDomainServices();
  final _transportadoraServices = TransportadoraDomainServices();

  final _searchListModel = SearchListModel<Viagem>();
  List<Viagem> _todasAsViagens = [];

  final Map<int, String> _motoristasNomes = {};
  final Map<int, String> _veiculosPlacas = {};
  final Map<int, String> _transportadorasNomes = {};

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    final motoristas = await _motoristaServices.findAll();
    final veiculos = await _veiculoServices.findAll();
    final transportadoras = await _transportadoraServices.findAll();

    for (var m in motoristas) {
      _motoristasNomes[m.id!] = m.nome;
    }
    for (var v in veiculos) {
      _veiculosPlacas[v.id!] = '${v.tipo} (${v.placa})';
    }
    for (var t in transportadoras) {
      _transportadorasNomes[t.id!] = t.nomeFantasia;
    }

    await _buscarTodasViagens();
  }

  Future<void> _buscarTodasViagens() async {
    final dados = await _viagemServices.findAll();
    _todasAsViagens = dados;
    _searchListModel.setData(dados);
    setState(() {
      _carregando = false;
    });
  }

  void _filtrarLista(String query) {
    if (query.isEmpty) {
      _searchListModel.setData(_todasAsViagens);
    } else {
      final filtradas = _todasAsViagens.where((v) {
        return v.destino.toLowerCase().contains(query.toLowerCase()) ||
            v.origem.toLowerCase().contains(query.toLowerCase()) ||
            v.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _searchListModel.setData(filtradas);
    }
  }

  Color _obterCorStatus(String status) {
    switch (status) {
      case 'Pendente':
        return Colors.grey;
      case 'Em transito':
        return Colors.orange;
      case 'Atrasado':
        return Colors.red;
      case 'Concluido':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoramento de Rotas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Viagem',
                hintText: 'Digite o destino ou status',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: _searchListModel,
                builder: (context, child) {
                  final lista = _searchListModel.data;

                  if (lista.isEmpty) {
                    return const Center(child: Text('Nenhuma viagem planejada até o momento.'));
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final viagem = lista[index];
                      final motoristaNome = _motoristasNomes[viagem.idMotorista] ?? 'Não encontrado';
                      final veiculoPlaca = _veiculosPlacas[viagem.idVeiculo] ?? 'Não encontrado';
                      
                      final transportadoraNome = viagem.idTransportadora != null
                          ? (_transportadorasNomes[viagem.idTransportadora] ?? 'Não encontrado')
                          : 'Frota Própria (Interno)';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.viagemDetalhes,
                              arguments: viagem,
                            );
                            _buscarTodasViagens();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${viagem.origem} ➔ ${viagem.destino}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _obterCorStatus(viagem.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        viagem.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('Operador: $transportadoraNome', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('Motorista: $motoristaNome', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text('Veículo: $veiculoPlaca', style: const TextStyle(color: Colors.grey)),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Custo: R\$ ${viagem.custoTransporte.toStringAsFixed(2)}'),
                                    Text('Carga: ${viagem.pesoTotal.toStringAsFixed(1)} kg'),
                                    Text(
                                      viagem.faturado ? 'FATURADO' : 'NÃO FATURADO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: viagem.faturado ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}