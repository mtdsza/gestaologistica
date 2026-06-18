import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/veiculo.dart';
import 'package:gestao_logistica/domain/services/veiculo_domain_services.dart';

class VeiculoPage extends StatefulWidget {
  const VeiculoPage({super.key});

  @override
  State<VeiculoPage> createState() => _VeiculoPageState();
}

class _VeiculoPageState extends State<VeiculoPage> {
  final _placaController = TextEditingController();
  final _capacidadeController = TextEditingController();

  String _tipoSelecionado = 'Fiorino';
  String _statusSelecionado = 'Disponivel';

  final _formState = GlobalKey<FormState>();
  final _veiculoServices = VeiculoDomainServices();

  Veiculo? _veiculoEntity;

  @override
  void dispose() {
    _placaController.dispose();
    _capacidadeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final currentState = _formState.currentState;
    if (currentState == null || !currentState.validate()) return;

    final capacidade = double.parse(_capacidadeController.text);

    if (_veiculoEntity == null) {
      final novoVeiculo = Veiculo(
        placa: _placaController.text.toUpperCase(), // salva a placa sempre em maiúscula
        tipo: _tipoSelecionado,
        capacidadeCarga: capacidade,
        status: _statusSelecionado,
      );
      _veiculoServices.insert(novoVeiculo);
    } else {
      final veiculoAtualizado = Veiculo(
        id: _veiculoEntity!.id,
        placa: _placaController.text.toUpperCase(),
        tipo: _tipoSelecionado,
        capacidadeCarga: capacidade,
        status: _statusSelecionado,
      );
      _veiculoServices.update(veiculoAtualizado);
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
      final param = ModalRoute.of(context)!.settings.arguments as Veiculo;
      _veiculoEntity = param;

      _placaController.text = _veiculoEntity!.placa;
      _capacidadeController.text = _veiculoEntity!.capacidadeCarga.toString();
      _tipoSelecionado = _veiculoEntity!.tipo;
      _statusSelecionado = _veiculoEntity!.status;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_veiculoEntity == null ? 'Novo Veículo' : 'Editar Veículo'),
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
                controller: _placaController,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'Ex: ABC-1234 ou ABC1D23',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório!';
                  }
                  if (value.length < 7) {
                    return 'A placa deve conter no mínimo 7 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacidadeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Capacidade Máxima de Carga (kg)',
                  hintText: 'Ex: 1500.0',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório!';
                  }
                  final valorNumerico = double.tryParse(value);
                  if (valorNumerico == null || valorNumerico <= 0) {
                    return 'Digite um valor numérico válido e maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Veículo',
                ),
                items: const [
                  DropdownMenuItem(value: 'Fiorino', child: Text('Fiorino')),
                  DropdownMenuItem(value: 'Caminhao Bau', child: Text('Caminhão Baú')),
                  DropdownMenuItem(value: 'Carreta', child: Text('Carreta')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoSelecionado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status do Veículo',
                ),
                items: const [
                  DropdownMenuItem(value: 'Disponivel', child: Text('Disponível')),
                  DropdownMenuItem(value: 'Manutencao', child: Text('Em Manutenção')),
                  DropdownMenuItem(value: 'Em Viagem', child: Text('Em Viagem')),
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