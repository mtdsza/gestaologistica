import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';

class MotoristaPage extends StatefulWidget {
  const MotoristaPage({super.key});

  @override
  State<MotoristaPage> createState() => _MotoristaPageState();
}

class _MotoristaPageState extends State<MotoristaPage> {
  final _nomeController = TextEditingController();
  final _cnhController = TextEditingController();
  
  String _statusSelecionado = 'Disponivel';

  final _formState = GlobalKey<FormState>();
  final _motoristaServices = MotoristaDomainServices();
  
  Motorista? _motoristaEntity;

  @override
  void dispose() {
    _nomeController.dispose();
    _cnhController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final currentState = _formState.currentState;
    if (currentState == null || !currentState.validate()) return;

    if (_motoristaEntity == null) {
      final novoMotorista = Motorista(
        nome: _nomeController.text,
        cnh: _cnhController.text,
        status: _statusSelecionado,
      );
      _motoristaServices.insert(novoMotorista);
    } else {
      final motoristaAtualizado = Motorista(
        id: _motoristaEntity!.id,
        nome: _nomeController.text,
        cnh: _cnhController.text,
        status: _statusSelecionado,
      );
      _motoristaServices.update(motoristaAtualizado);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operação realizada com sucesso!'),
        duration: Duration(milliseconds: 2000),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final param = ModalRoute.of(context)!.settings.arguments as Motorista;
      _motoristaEntity = param;
      
      _nomeController.text = _motoristaEntity!.nome;
      _cnhController.text = _motoristaEntity!.cnh;
      _statusSelecionado = _motoristaEntity!.status;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_motoristaEntity == null ? 'Novo Motorista' : 'Editar Motorista'),
        actions: [
          IconButton(
            onPressed: _onSubmit,
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formState,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório!';
                  }
                  if (value.length <= 3) {
                    return 'O nome deve ter mais de 3 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnhController,
                maxLength: 11,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CNH',
                  hintText: 'Digite apenas números',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório!';
                  }
                  if (value.length < 11) {
                    return 'A CNH deve conter 11 dígitos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status de Disponibilidade',
                ),
                items: const [
                  DropdownMenuItem(value: 'Disponivel', child: Text('Disponível')),
                  DropdownMenuItem(value: 'Em Viagem', child: Text('Em Viagem')),
                  DropdownMenuItem(value: 'Inativo', child: Text('Inativo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statusSelecionado = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        child: const Icon(Icons.check),
      ),
    );
  }
}