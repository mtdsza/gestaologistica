import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/search_list_model.dart';
import 'package:gestao_logistica/domain/entities/usuario.dart';
import 'package:gestao_logistica/domain/services/usuario_domain_services.dart';
import 'package:gestao_logistica/domain/services/usuario_services.dart';
import 'package:gestao_logistica/routes.dart';

class SearchUsuarioPage extends StatefulWidget {
  const SearchUsuarioPage({super.key});

  @override
  State<SearchUsuarioPage> createState() => _SearchUsuarioPageState();
}

class _SearchUsuarioPageState extends State<SearchUsuarioPage> {
  final _services = UsuarioServices();
  final _searchListModel = SearchListModel<Usuario>();
  List<Usuario> _todosOsRegistros = [];

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
      final filtrados = _todosOsRegistros.where((u) {
        return u.username.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _searchListModel.setData(filtrados);
    }
  }

  Future<void> _alternarStatusUsuario(Usuario item, bool novoStatus) async {
    await _services.updateAtivo(item.id!, novoStatus);
    _buscarTodos();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioLogado = UsuarioDomainServices.usuarioLogado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Usuários'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _filtrarLista,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'Digite o nome do usuário',
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
                    return const Center(child: Text('Nenhum usuário cadastrado.'));
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final item = lista[index];
                      
                      // impede o administrador de desativar sua própria sessão de login ativa
                      final eOProprioUsuarioConectado = usuarioLogado != null && usuarioLogado.id == item.id;

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            item.isAdmin ? Icons.admin_panel_settings : Icons.person_pin,
                            color: item.ativo
                                ? (item.isAdmin ? Colors.blue : Colors.grey)
                                : Colors.red[200],
                          ),
                          title: Text(
                            item.username,
                            style: TextStyle(
                              decoration: item.ativo ? TextDecoration.none : TextDecoration.lineThrough,
                              color: item.ativo ? Colors.black : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            item.isAdmin 
                                ? 'Perfil: Administrador' 
                                : 'Perfil: Motorista (ID Motorista: ${item.idMotorista})',
                            style: TextStyle(color: item.ativo ? Colors.black54 : Colors.grey),
                          ),
                          
                          // switch de ativação/desativação
                          trailing: Switch(
                            value: item.ativo,
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.red[100],
                            inactiveThumbColor: Colors.red,
                            // se for o próprio usuário, desativa o botão
                            onChanged: eOProprioUsuarioConectado
                                ? null
                                : (value) => _alternarStatusUsuario(item, value),
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
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.usuariosCadastro);
          _buscarTodos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}