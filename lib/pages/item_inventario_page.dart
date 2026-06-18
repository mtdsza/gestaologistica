import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/distancia_helper.dart';
import 'package:gestao_logistica/domain/entities/item_inventario.dart';
import 'package:gestao_logistica/domain/services/item_inventario_domain_services.dart';

class ItemInventarioPage extends StatefulWidget {
  const ItemInventarioPage({super.key});

  @override
  State<ItemInventarioPage> createState() => _ItemInventarioPageState();
}

class _ItemInventarioPageState extends State<ItemInventarioPage> {
  final _nomeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _localizacaoController = TextEditingController();

  String _tipoSelecionado = 'Geral';
  String _cidadeSelecionada = 'Sao Paulo';

  final _formState = GlobalKey<FormState>();
  final _itemServices = ItemInventarioDomainServices();

  ItemInventario? _itemEntity;

  @override
  void dispose() {
    _nomeController.dispose();
    _pesoController.dispose();
    _quantidadeController.dispose();
    _validadeController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final hoje = DateTime.now();
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(hoje.year - 2),
      lastDate: DateTime(hoje.year + 5),
    );

    if (dataSelecionada != null) {
      setState(() {
        _validadeController.text = dataSelecionada.toString().split(' ')[0];
      });
    }
  }

  void _onSubmit() {
    final currentState = _formState.currentState;
    if (currentState == null || !currentState.validate()) return;

    if (_tipoSelecionado == 'Perecivel' && _validadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe a data de validade para itens perecíveis.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final peso = double.parse(_pesoController.text);
    final quantidade = int.parse(_quantidadeController.text);

    if (_itemEntity == null) {
      final novoItem = ItemInventario(
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        pesoUnitario: peso,
        quantidade: quantidade,
        cidade: _cidadeSelecionada,
        dataValidade: _tipoSelecionado == 'Perecivel' ? _validadeController.text : null,
        localizacao: _localizacaoController.text,
      );
      _itemServices.insert(novoItem);
    } else {
      final itemAtualizado = ItemInventario(
        id: _itemEntity!.id,
        nome: _nomeController.text,
        tipo: _tipoSelecionado,
        pesoUnitario: peso,
        quantidade: quantidade,
        cidade: _cidadeSelecionada,
        dataValidade: _tipoSelecionado == 'Perecivel' ? _validadeController.text : null,
        localizacao: _localizacaoController.text,
      );
      _itemServices.update(itemAtualizado);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operação realizada com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null && _itemEntity == null) {
      final param = ModalRoute.of(context)!.settings.arguments as ItemInventario;
      _itemEntity = param;

      _nomeController.text = _itemEntity!.nome;
      _pesoController.text = _itemEntity!.pesoUnitario.toString();
      _quantidadeController.text = _itemEntity!.quantidade.toString();
      _tipoSelecionado = _itemEntity!.tipo;
      _cidadeSelecionada = _itemEntity!.cidade;
      _validadeController.text = _itemEntity!.dataValidade ?? '';
      _localizacaoController.text = _itemEntity!.localizacao ?? '';
    }

    final listaCidades = DistanciaHelper.cidades.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_itemEntity == null ? 'Nova Mercadoria' : 'Ajustar Mercadoria'),
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
                controller: _nomeController,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Peso Unitário (kg)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Digite um peso maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade em Estoque'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório!';
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Digite uma quantidade maior ou igual a zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // seleção do polo geográfico
              DropdownButtonFormField<String>(
                value: _cidadeSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Centro de Distribuição (Cidade)',
                ),
                items: listaCidades.map((cidade) {
                  return DropdownMenuItem(value: cidade, child: Text(cidade));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _cidadeSelecionada = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _localizacaoController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Local de Armazenamento (Fácil Acesso)',
                  hintText: 'Ex: Corredor B - Prateleira 4',
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(labelText: 'Categoria de Armazenamento'),
                items: const [
                  DropdownMenuItem(value: 'Geral', child: Text('Carga Geral')),
                  DropdownMenuItem(value: 'Eletronico', child: Text('Eletrônico')),
                  DropdownMenuItem(value: 'Perecivel', child: Text('Perecível')),
                  DropdownMenuItem(value: 'Fragil', child: Text('Frágil')),
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

              if (_tipoSelecionado == 'Perecivel')
                TextFormField(
                  controller: _validadeController,
                  readOnly: true,
                  onTap: () => _selecionarData(context),
                  decoration: const InputDecoration(
                    labelText: 'Data de Validade',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
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