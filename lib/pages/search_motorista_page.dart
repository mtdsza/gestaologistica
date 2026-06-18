import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

enum ListViewItemMenu { delete, edit, history }

class SearchMotoristaPage extends StatefulWidget {
  const SearchMotoristaPage({super.key});

  @override
  State<SearchMotoristaPage> createState() => _SearchMotoristaPageState();
}

class _SearchMotoristaPageState extends State<SearchMotoristaPage> {
  final _services = MotoristaDomainServices();
  final _viagemServices = ViagemDomainServices();
  final _searchListModel = SearchListModel<Motorista>();
  List<Motorista> _todosOsRegistros = [];

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
      final filtrados = _todosOsRegistros.where((m) {
        return m.nome.toLowerCase().contains(query.toLowerCase()) ||
            m.cnh.contains(query);
      }).toList();
      _searchListModel.setData(filtrados);
    }
  }

  Future<void> _exibirFormulario(Motorista? item) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.motoristasCadastro,
      arguments: item,
    );
    _buscarTodos();
  }

  void _onMenuSelecionado(ListViewItemMenu acao, Motorista item) async {
    switch (acao) {
      case ListViewItemMenu.delete:
        await _services.delete(item);
        _buscarTodos();
        break;
      case ListViewItemMenu.edit:
        _exibirFormulario(item);
        break;
      case ListViewItemMenu.history:
        _exibirHistoricoMotorista(item);
        break;
    }
  }

  void _exibirHistoricoMotorista(Motorista motorista) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Histórico: ${motorista.nome}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<List<Viagem>>(
              future: _viagemServices.findHistoryByMotorista(motorista.id!),
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
                    child: Text('Nenhuma rota registrada para este motorista.', textAlign: TextAlign.center),
                  );
                }

                return ListView.builder(
                  itemCount: viagens.length,
                  itemBuilder: (context, index) {
                    final rota = viagens[index];
                    return ListTile(
                      leading: const Icon(Icons.map_outlined),
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
      case 'Inativo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motoristas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Digite o nome ou CNH',
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
                          title: Text(item.nome),
                          subtitle: Text('CNH: ${item.cnh} | Status: ${item.status}'),
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