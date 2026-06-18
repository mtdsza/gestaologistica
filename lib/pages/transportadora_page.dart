import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/transportadora.dart';
import 'package:gestao_logistica/domain/services/transportadora_domain_services.dart';

class TransportadoraPage extends StatefulWidget {
  const TransportadoraPage({super.key});

  @override
  State<TransportadoraPage> createState() => _TransportadoraPageState();
}

class _TransportadoraPageState extends State<TransportadoraPage> {
  final _cnpjController = TextEditingController();
  final _nomeController = TextEditingController();
  final _custoKmController = TextEditingController(text: '3.00');
  final _custoPesoController = TextEditingController(text: '0.15');

  final _formState = GlobalKey<FormState>();
  final _transportadoraServices = TransportadoraDomainServices();

  Transportadora? _transportadoraEntity;

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeController.dispose();
    _custoKmController.dispose();
    _custoPesoController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final currentState = _formState.currentState;
    if (currentState == null || !currentState.validate()) return;

    final custoKm = double.parse(_custoKmController.text);
    final custoPeso = double.parse(_custoPesoController.text);

    if (_transportadoraEntity == null) {
      final novaTransportadora = Transportadora(
        cnpj: _cnpjController.text,
        nomeFantasia: _nomeController.text,
        custoKm: custoKm,
        custoPeso: custoPeso,
      );
      _transportadoraServices.insert(novaTransportadora);
    } else {
      final transportadoraAtualizada = Transportadora(
        id: _transportadoraEntity!.id,
        cnpj: _cnpjController.text,
        nomeFantasia: _nomeController.text,
        custoKm: custoKm,
        custoPeso: custoPeso,
      );
      _transportadoraServices.update(transportadoraAtualizada);
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
    if (ModalRoute.of(context)!.settings.arguments != null && _transportadoraEntity == null) {
      final param = ModalRoute.of(context)!.settings.arguments as Transportadora;
      _transportadoraEntity = param;
      
      _cnpjController.text = _transportadoraEntity!.cnpj;
      _nomeController.text = _transportadoraEntity!.nomeFantasia;
      _custoKmController.text = _transportadoraEntity!.custoKm.toString();
      _custoPesoController.text = _transportadoraEntity!.custoPeso.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_transportadoraEntity == null ? 'Nova Transportadora' : 'Editar Transportadora'),
        actions: [
          IconButton(
            onPressed: _onSubmit,
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formState,
          child: Column(
            children: [
              TextFormField(
                controller: _cnpjController,
                maxLength: 14,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  hintText: 'Digite apenas números',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  if (value.length < 14) return 'O CNPJ deve conter 14 dígitos.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nome Fantasia',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  if (value.length <= 3) return 'O nome deve ter mais de 3 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _custoKmController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custo por Quilômetro Rodado (R\$/km)',
                  hintText: 'Ex: 3.50',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  final valor = double.tryParse(value);
                  if (valor == null || valor < 0) return 'Digite um custo por km válido.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _custoPesoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custo por Quilograma de Carga (R\$/kg)',
                  hintText: 'Ex: 0.15',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  final valor = double.tryParse(value);
                  if (valor == null || valor < 0) return 'Digite um custo por kg válido.';
                  return null;
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