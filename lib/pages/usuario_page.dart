import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/usuario.dart';
import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';
import 'package:gestao_logistica/domain/services/usuario_services.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isAdmin = true;
  int? _motoristaSelecionadoId;

  final _formState = GlobalKey<FormState>();
  final _usuarioServices = UsuarioServices();
  final _motoristaServices = MotoristaDomainServices();

  List<Motorista> _todosOsMotoristas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMotoristas();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _carregarMotoristas() async {
    final motoristas = await _motoristaServices.findAll();
    setState(() {
      _todosOsMotoristas = motoristas;
      _carregando = false;
    });
  }

  void _onSubmit() async {
    final currentState = _formState.currentState;
    if (currentState == null || !currentState.validate()) return;

    if (!_isAdmin && _motoristaSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Um usuário de perfil motorista precisa ser associado a um profissional cadastrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final novoUsuario = Usuario(
      username: _usernameController.text,
      password: _passwordController.text,
      isAdmin: _isAdmin,
      idMotorista: _isAdmin ? null : _motoristaSelecionadoId,
    );

    await _usuarioServices.insert(novoUsuario);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );

    Navigator.pop(context);
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
        title: const Text('Cadastrar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formState,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: 'Nome de Usuário (Login)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                maxLength: 20,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha de Acesso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  if (value.length < 6) return 'A senha deve possuir pelo menos 6 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Perfil Administrador'),
                subtitle: const Text('Acesso total ao Painel de Controle e cadastros.'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                    if (_isAdmin) {
                      _motoristaSelecionadoId = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              if (!_isAdmin)
                DropdownButtonFormField<int>(
                  value: _motoristaSelecionadoId,
                  decoration: const InputDecoration(
                    labelText: 'Selecione o Motorista Profissional',
                    border: OutlineInputBorder(),
                  ),
                  items: _todosOsMotoristas.isEmpty
                      ? const [DropdownMenuItem(value: null, child: Text('Nenhum motorista cadastrado no sistema'))]
                      : _todosOsMotoristas.map((m) {
                          return DropdownMenuItem(value: m.id, child: Text(m.nome));
                        }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _motoristaSelecionadoId = value;
                    });
                  },
                ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Gravar Usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}