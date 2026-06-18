import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/item_inventario.dart';
import 'package:gestao_logistica/domain/services/item_inventario_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

enum ListViewItemMenu { delete, edit }

class SearchItemInventarioPage extends StatefulWidget {
  const SearchItemInventarioPage({super.key});

  @override
  State<SearchItemInventarioPage> createState() => _SearchItemInventarioPageState();
}

class _SearchItemInventarioPageState extends State<SearchItemInventarioPage> {
  final _services = ItemInventarioDomainServices();
  final _searchListModel = SearchListModel<ItemInventario>();
  List<ItemInventario> _todosOsRegistros = [];

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
      final filtrados = _todosOsRegistros.where((item) {
        return item.nome.toLowerCase().contains(query.toLowerCase()) ||
            item.tipo.toLowerCase().contains(query.toLowerCase()) ||
            item.cidade.toLowerCase().contains(query.toLowerCase()) ||
            (item.localizacao?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      _searchListModel.setData(filtrados);
    }
  }

  bool _verificarSeEstaVencido(String? dataValidade) {
    if (dataValidade == null || dataValidade.isEmpty) return false;
    final validade = DateTime.tryParse(dataValidade);
    if (validade == null) return false;

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    return validade.isBefore(hojeSemHora);
  }

  Future<void> _exibirFormulario(ItemInventario? item) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.estoqueCadastro,
      arguments: item,
    );
    _buscarTodos();
  }

  void _onMenuSelecionado(ListViewItemMenu acao, ItemInventario item) async {
    switch (acao) {
      case ListViewItemMenu.delete:
        await _services.delete(item);
        _buscarTodos();
        break;
      case ListViewItemMenu.edit:
        _exibirFormulario(item);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Estoque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Digite a descrição, categoria, CD ou setor',
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
                      final semEstoque = item.quantidade == 0;
                      final vencido = _verificarSeEstaVencido(item.dataValidade);
                      
                      final localEstoque = item.localizacao != null && item.localizacao!.isNotEmpty
                          ? item.localizacao!
                          : 'Setor Geral';

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.archive,
                            color: vencido
                                ? Colors.red
                                : (semEstoque ? Colors.orange : Colors.blue),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.nome),
                              if (vencido)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'VENCIDO',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Polo: ${item.cidade} | Categoria: ${item.tipo} | Unitário: ${item.pesoUnitario} kg'
                            '\nSaldo: ${item.quantidade} un ${item.dataValidade != null ? "| Val: ${item.dataValidade}" : ""}'
                            '\nLocal: $localEstoque',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<ListViewItemMenu>(
                            onSelected: (value) => _onMenuSelecionado(value, item),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: ListViewItemMenu.edit,
                                child: Text('Ajustar'),
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