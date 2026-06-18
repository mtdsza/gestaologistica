import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/veiculo.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/veiculo_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

enum ListViewItemMenu { delete, edit, history }

class SearchVeiculoPage extends StatefulWidget {
  const SearchVeiculoPage({super.key});

  @override
  State<SearchVeiculoPage> createState() => _SearchVeiculoPageState();
}

class _SearchVeiculoPageState extends State<SearchVeiculoPage> {
  final _services = VeiculoDomainServices();
  final _viagemServices = ViagemDomainServices();
  final _searchListModel = SearchListModel<Veiculo>();
  List<Veiculo> _todosOsRegistros = [];

  @override
  void initState() {
    super.initState();
    _buscarTodos();
  }

  Future<void> _buscarTodos() async {
    final dados = await _services.findAll();
    _todosOsRegistros = dados;
    _searchListModel.setData(dados);
  }

  void _filtrarLista(String query) {
    if (query.isEmpty) {
      _searchListModel.setData(_todosOsRegistros);
    } else {
      final filtrados = _todosOsRegistros.where((v) {
        return v.placa.toLowerCase().contains(query.toLowerCase()) ||
            v.tipo.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _searchListModel.setData(filtrados);
    }
  }

  Future<void> _exibirFormulario(Veiculo? item) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.veiculosCadastro,
      arguments: item,
    );
    _buscarTodos();
  }

  void _onMenuSelecionado(ListViewItemMenu acao, Veiculo item) async {
    switch (acao) {
      case ListViewItemMenu.delete:
        await _services.delete(item);
        _buscarTodos();
        break;
      case ListViewItemMenu.edit:
        _exibirFormulario(item);
        break;
      case ListViewItemMenu.history:
        _exibirHistoricoVeiculo(item);
        break;
    }
  }

  void _exibirHistoricoVeiculo(Veiculo veiculo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Histórico: Placa ${veiculo.placa}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<List<Viagem>>(
              future: _viagemServices.findHistoryByVeiculo(veiculo.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar o histórico de rotas.'));
                }

                final viagens = snapshot.data ?? [];
                if (viagens.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma rota registrada para este veículo.', textAlign: TextAlign.center),
                  );
                }

                return ListView.builder(
                  itemCount: viagens.length,
                  itemBuilder: (context, index) {
                    final rota = viagens[index];
                    return ListTile(
                      leading: const Icon(Icons.local_shipping_outlined),
                      title: Text('${rota.origem} ➔ ${rota.destino}'),
                      subtitle: Text('Data: ${rota.dataPlanejada} | Status: ${rota.status}'),
                      trailing: Text('R\$ ${rota.custoTransporte.toStringAsFixed(2)}'),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Color _obterCorStatus(String status) {
    switch (status) {
      case 'Disponivel':
        return Colors.green;
      case 'Em Viagem':
        return Colors.orange;
      case 'Manutencao':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Digite a placa ou tipo',
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
                    return const Center(child: Text('Nenhum registro encontrado.'));
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final item = lista[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _obterCorStatus(item.status),
                            radius: 12,
                          ),
                          title: Text('Placa: ${item.placa}'),
                          subtitle: Text(
                            'Tipo: ${item.tipo} | Carga Máx: ${item.capacidadeCarga} kg\nStatus: ${item.status}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<ListViewItemMenu>(
                            onSelected: (value) => _onMenuSelecionado(value, item),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: ListViewItemMenu.edit,
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem(
                                value: ListViewItemMenu.history,
                                child: Text('Histórico de Viagens'),
                              ),
                              const PopupMenuItem(
                                value: ListViewItemMenu.delete,
                                child: Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exibirFormulario(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}