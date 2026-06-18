import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/transportadora.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/transportadora_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

enum ListViewItemMenu { delete, edit, history }

class SearchTransportadoraPage extends StatefulWidget {
  const SearchTransportadoraPage({super.key});

  @override
  State<SearchTransportadoraPage> createState() => _SearchTransportadoraPageState();
}

class _SearchTransportadoraPageState extends State<SearchTransportadoraPage> {
  final _services = TransportadoraDomainServices();
  final _viagemServices = ViagemDomainServices();
  final _searchListModel = SearchListModel<Transportadora>();
  List<Transportadora> _todosOsRegistros = [];

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
      final filtrados = _todosOsRegistros.where((t) {
        return t.nomeFantasia.toLowerCase().contains(query.toLowerCase()) ||
            t.cnpj.contains(query);
      }).toList();
      _searchListModel.setData(filtrados);
    }
  }

  Future<void> _exibirFormulario(Transportadora? item) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.transportadorasCadastro,
      arguments: item,
    );
    _buscarTodos();
  }

  void _onMenuSelecionado(ListViewItemMenu acao, Transportadora item) async {
    switch (acao) {
      case ListViewItemMenu.delete:
        await _services.delete(item);
        _buscarTodos();
        break;
      case ListViewItemMenu.edit:
        _exibirFormulario(item);
        break;
      case ListViewItemMenu.history:
        _exibirHistoricoTransportadora(item);
        break;
    }
  }

  void _exibirHistoricoTransportadora(Transportadora transportadora) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Relatório: ${transportadora.nomeFantasia}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: FutureBuilder<List<Viagem>>(
              future: _viagemServices.findHistoryByTransportadora(transportadora.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar o histórico de rotas.'));
                }

                final viagens = snapshot.data ?? [];
                if (viagens.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'Nenhuma rota agendada para esta transportadora.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final gastoAcumulado = viagens
                    .where((v) => v.status == 'Concluido')
                    .fold(0.0, (sum, v) => sum + v.custoTransporte);

                final concluidas = viagens.where((v) => v.status == 'Concluido').length;
                final eficiencia = (concluidas / viagens.length) * 100.0;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Gasto Acumulado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${gastoAcumulado.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Eficiência Média', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  '${eficiencia.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Histórico de Viagens:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: viagens.length,
                        itemBuilder: (context, index) {
                          final rota = viagens[index];
                          return Card(
                            child: ListTile(
                              title: Text('${rota.origem} ➔ ${rota.destino}'),
                              subtitle: Text('Data: ${rota.dataPlanejada} | Status: ${rota.status}'),
                              trailing: Text('R\$ ${rota.custoTransporte.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportadoras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Digite o nome ou CNPJ',
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
                          leading: const Icon(Icons.business),
                          title: Text(item.nomeFantasia),
                          subtitle: Text(
                            'CNPJ: ${item.cnpj}\n'
                            'Tarifa: R\$ ${item.custoKm.toStringAsFixed(2)}/km e R\$ ${item.custoPeso.toStringAsFixed(2)}/kg',
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
                                child: Text('Histórico e Indicadores'),
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