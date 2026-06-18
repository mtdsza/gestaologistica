import 'package:flutter/material.dart';
import 'package:gestao_logistica/core/distancia_helper.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/entities/motorista.dart';
import 'package:gestao_logistica/domain/entities/veiculo.dart';
import 'package:gestao_logistica/domain/entities/item_inventario.dart';
import 'package:gestao_logistica/domain/entities/transportadora.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';
import 'package:gestao_logistica/domain/services/veiculo_domain_services.dart';
import 'package:gestao_logistica/domain/services/item_inventario_domain_services.dart';
import 'package:gestao_logistica/domain/services/transportadora_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';

class ViagemPage extends StatefulWidget {
  const ViagemPage({super.key});

  @override
  State<ViagemPage> createState() => _ViagemPageState();
}

class _ViagemPageState extends State<ViagemPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _custoController = TextEditingController();
  
  // controladores para tarifas customizadas de frete
  final _custoKmPersonalizadoController = TextEditingController(text: '3.00');
  final _custoPesoPersonalizadoController = TextEditingController(text: '0.15');

  final _viagemServices = ViagemDomainServices();
  final _motoristaServices = MotoristaDomainServices();
  final _veiculoServices = VeiculoDomainServices();
  final _itemServices = ItemInventarioDomainServices();
  final _transportadoraServices = TransportadoraDomainServices();

  List<Motorista> _todosOsMotoristas = [];
  List<Veiculo> _todosOsVeiculos = [];
  List<ItemInventario> _todosOsItens = [];
  List<Transportadora> _transportadoras = [];

  List<Motorista> _motoristasFiltrados = [];
  List<Veiculo> _veiculosFiltrados = [];
  List<ItemInventario> _itensFiltrados = [];

  int? _motoristaSelecionadoId;
  int? _veiculoSelecionadoId;
  int? _transportadoraSelecionadaId;

  String _origemSelecionada = 'Sao Paulo';
  String _destinoSelecionada = 'Rio de Janeiro';
  double _distanciaCalculada = 0.0;

  bool _calcularCustoAutomaticamente = true;

  final Map<int, int> _quantidadesSelecionadas = {};
  final Map<int, TextEditingController> _itemControllers = {};

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _custoController.dispose();
    _custoKmPersonalizadoController.dispose();
    _custoPesoPersonalizadoController.dispose();
    _itemControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final motoristas = await _motoristaServices.findAvailable();
    final veiculos = await _veiculoServices.findAvailable();
    final itens = await _itemServices.findAll();
    final transportadoras = await _transportadoraServices.findAll();

    for (var item in itens) {
      _itemControllers[item.id!] = TextEditingController(text: '0');
    }

    setState(() {
      _todosOsMotoristas = motoristas;
      _todosOsVeiculos = veiculos;
      _todosOsItens = itens;
      _transportadoras = transportadoras;
      _carregando = false;
    });

    _aplicarFiltroPorOperador(null);
  }

  void _aplicarFiltroPorOperador(int? transportadoraId) {
    setState(() {
      _transportadoraSelecionadaId = transportadoraId;

      _motoristasFiltrados = _todosOsMotoristas
          .where((m) => m.idTransportadora == transportadoraId)
          .toList();

      _veiculosFiltrados = _todosOsVeiculos
          .where((v) => v.idTransportadora == transportadoraId)
          .toList();

      _itensFiltrados = _todosOsItens
          .where((item) => item.cidade == _origemSelecionada)
          .toList();

      _motoristaSelecionadoId = null;
      _veiculoSelecionadoId = null;
      _resetarSelecaoDeItens();
      _recalcularDistanciaECusto();
    });
  }

  void _filtrarEstoquePorOrigem(String cidade) {
    setState(() {
      _origemSelecionada = cidade;
      _itensFiltrados = _todosOsItens
          .where((item) => item.cidade == _origemSelecionada)
          .toList();

      _resetarSelecaoDeItens();
      _recalcularDistanciaECusto();
    });
  }

  bool _estaVencido(String? dataValidade) {
    if (dataValidade == null || dataValidade.isEmpty) return false;
    final validade = DateTime.tryParse(dataValidade);
    if (validade == null) return false;

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    return validade.isBefore(hojeSemHora);
  }

  void _recalcularDistanciaECusto() {
    if (_origemSelecionada == _destinoSelecionada) {
      setState(() {
        _distanciaCalculada = 0.0;
        _custoController.text = '0.00';
      });
      return;
    }

    final pesoTotal = _calcularPesoTotal();
    final distancia = DistanciaHelper.calcularDistanciaEmKm(_origemSelecionada, _destinoSelecionada);

    double custoKm = 3.00;
    double custoPeso = 0.15;

    if (_calcularCustoAutomaticamente) {
      // se automático, lê os padrões do banco de dados (da transportadora ou frota própria)
      if (_transportadoraSelecionadaId != null) {
        final trans = _transportadoras.firstWhere((t) => t.id == _transportadoraSelecionadaId);
        custoKm = trans.custoKm;
        custoPeso = trans.custoPeso;
      }
      _custoKmPersonalizadoController.text = custoKm.toStringAsFixed(2);
      _custoPesoPersonalizadoController.text = custoPeso.toStringAsFixed(2);
    } else {
      // se desmarcado, lê as taxas decimais que o usuário digitar
      custoKm = double.tryParse(_custoKmPersonalizadoController.text) ?? 3.00;
      custoPeso = double.tryParse(_custoPesoPersonalizadoController.text) ?? 0.15;
    }

    final custoDistancia = distancia * custoKm;
    final custoCarga = pesoTotal * custoPeso;
    final custoTotal = custoDistancia + custoCarga;

    setState(() {
      _distanciaCalculada = distancia;
      _custoController.text = custoTotal.toStringAsFixed(2);
    });
  }

  double _calcularPesoTotal() {
    double pesoAcumulado = 0.0;
    _quantidadesSelecionadas.forEach((itemId, quantidade) {
      if (quantidade > 0) {
        final item = _todosOsItens.firstWhere((i) => i.id == itemId);
        pesoAcumulado += item.pesoUnitario * quantidade;
      }
    });
    return pesoAcumulado;
  }

  void _resetarSelecaoDeItens() {
    _quantidadesSelecionadas.clear();
    _itemControllers.forEach((key, controller) {
      controller.text = '0';
    });
  }

  Future<void> _salvarViagem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_motoristaSelecionadoId == null || _veiculoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um motorista e um veículo para a rota.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_origemSelecionada == _destinoSelecionada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A Origem não pode ser igual ao Destino.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pesoTotal = _calcularPesoTotal();
    if (pesoTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos um item com quantidade ao planejamento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final veiculo = _todosOsVeiculos.firstWhere((v) => v.id == _veiculoSelecionadoId);

    if (pesoTotal > veiculo.capacidadeCarga) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excesso de carga! Peso total (${pesoTotal.toStringAsFixed(1)} kg) '
            'excede a capacidade do veículo (${veiculo.capacidadeCarga.toStringAsFixed(1)} kg).',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    List<Map<String, dynamic>> itensViagem = [];
    _quantidadesSelecionadas.forEach((itemId, quantidade) {
      if (quantidade > 0) {
        itensViagem.add({
          'id_item': itemId,
          'quantidade_transportada': quantidade,
        });
      }
    });

    final custo = double.parse(_custoController.text);
    final novaViagem = Viagem(
      idMotorista: _motoristaSelecionadoId!,
      idVeiculo: _veiculoSelecionadoId!,
      idTransportadora: _transportadoraSelecionadaId,
      origem: _origemSelecionada,
      destino: _destinoSelecionada,
      custoTransporte: custo,
      status: 'Pendente',
      pesoTotal: pesoTotal,
      dataPlanejada: DateTime.now().toString().split(' ')[0],
      faturado: false,
    );

    await _viagemServices.insert(novaViagem, itensViagem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viagem planejada com sucesso!')),
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

    final pesoCalculado = _calcularPesoTotal();
    final listaCidades = DistanciaHelper.cidades.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejar Rota'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int?>(
                value: _transportadoraSelecionadaId,
                decoration: const InputDecoration(
                  labelText: 'Selecione a Frota/Transportadora',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Frota Própria (CD Interno)'),
                  ),
                  ..._transportadoras.map((t) {
                    return DropdownMenuItem<int?>(
                      value: t.id,
                      child: Text(t.nomeFantasia),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  _aplicarFiltroPorOperador(value);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _motoristaSelecionadoId,
                decoration: const InputDecoration(
                  labelText: 'Selecione o Motorista',
                  border: OutlineInputBorder(),
                ),
                items: _motoristasFiltrados.isEmpty
                    ? const [DropdownMenuItem(value: null, child: Text('Nenhum motorista disponível para este operador'))]
                    : _motoristasFiltrados.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.nome));
                      }).toList(),
                onChanged: _motoristasFiltrados.isEmpty
                    ? null
                    : (value) => setState(() => _motoristaSelecionadoId = value),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _veiculoSelecionadoId,
                decoration: const InputDecoration(
                  labelText: 'Selecione o Veículo',
                  border: OutlineInputBorder(),
                ),
                items: _veiculosFiltrados.isEmpty
                    ? const [DropdownMenuItem(value: null, child: Text('Nenhum veículo disponível para este operador'))]
                    : _veiculosFiltrados.map((v) {
                        return DropdownMenuItem(
                          value: v.id,
                          child: Text('${v.tipo} (Placa: ${v.placa} | Máx: ${v.capacidadeCarga} kg)'),
                        );
                      }).toList(),
                onChanged: _veiculosFiltrados.isEmpty
                    ? null
                    : (value) => setState(() => _veiculoSelecionadoId = value),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _origemSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Cidade de Origem',
                  border: OutlineInputBorder(),
                ),
                items: listaCidades.map((cidade) {
                  return DropdownMenuItem(value: cityConverter(cidade), child: Text(cidade));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _filtrarEstoquePorOrigem(value);
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _destinoSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Cidade de Destino',
                  border: OutlineInputBorder(),
                ),
                items: listaCidades.map((cidade) {
                  return DropdownMenuItem(value: cityConverter(cidade), child: Text(cidade));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _destinoSelecionada = value;
                    });
                    _recalcularDistanciaEPreco();
                  }
                },
              ),
              const SizedBox(height: 16),

              if (_origemSelecionada != _destinoSelecionada)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Distância estimada por GPS: ${_distanciaCalculada.toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                  ),
                ),

              const Divider(height: 32),

              const Text(
                'Lista de Itens Disponíveis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _itensFiltrados.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Nenhum item do estoque encontrado para este operador nesta filial de origem.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _itensFiltrados.length,
                      itemBuilder: (context, index) {
                        final item = _itensFiltrados[index];
                        final quantidadeAtual = _quantidadesSelecionadas[item.id] ?? 0;
                        final itemExpirado = _estaVencido(item.dataValidade);

                        return ListTile(
                          title: Text(item.nome),
                          subtitle: Text(
                            itemExpirado
                                ? 'PRODUTO VENCIDO - TRANSPORTE BLOQUEADO'
                                : 'Estoque: ${item.quantidade} un | Setor: ${item.localizacao ?? "Geral"}\nPeso Unit.: ${item.pesoUnitario} kg',
                            style: TextStyle(
                              color: itemExpirado ? Colors.red : Colors.grey,
                              fontWeight: itemExpirado ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: quantidadeAtual == 0
                                    ? null
                                    : () {
                                        final novaQtd = quantidadeAtual - 1;
                                        setState(() {
                                          _quantidadesSelecionadas[item.id!] = novaQtd;
                                          _itemControllers[item.id!]?.text = novaQtd.toString();
                                        });
                                        _recalcularDistanciaECusto();
                                      },
                              ),
                              SizedBox(
                                width: 50,
                                child: TextFormField(
                                  controller: _itemControllers[item.id!],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  enabled: !itemExpirado,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    final digitado = int.tryParse(value) ?? 0;
                                    
                                    if (digitado < 0) {
                                      _itemControllers[item.id!]?.text = '0';
                                      setState(() {
                                        _quantidadesSelecionadas[item.id!] = 0;
                                      });
                                    } else if (digitado > item.quantidade) {
                                      _itemControllers[item.id!]?.text = item.quantidade.toString();
                                      setState(() {
                                        _quantidadesSelecionadas[item.id!] = item.quantidade;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Quantidade limitada ao estoque máximo de ${item.quantidade} un.'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _quantidadesSelecionadas[item.id!] = digitado;
                                      });
                                    }
                                    _recalcularDistanciaECusto();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: itemExpirado || quantidadeAtual >= item.quantidade
                                    ? null
                                    : () {
                                        final novaQtd = quantidadeAtual + 1;
                                        setState(() {
                                          _quantidadesSelecionadas[item.id!] = novaQtd;
                                          _itemControllers[item.id!]?.text = novaQtd.toString();
                                        });
                                        _recalcularDistanciaECusto();
                                      },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const Divider(height: 32),

              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Peso Acumulado da Carga',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pesoCalculado.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _veiculoSelecionadoId != null &&
                                  pesoCalculado >
                                      _todosOsVeiculos
                                          .firstWhere((v) => v.id == _veiculoSelecionadoId)
                                          .capacidadeCarga
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Calcular custo automaticamente'),
                subtitle: const Text('Se desmarcado, as caixas abaixo serão liberadas para digitar tarifas customizadas.'),
                value: _calcularCustoAutomaticamente,
                onChanged: (value) {
                  setState(() {
                    _calcularCustoAutomaticamente = value ?? true;
                    _recalcularDistanciaECusto();
                  });
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _custoKmPersonalizadoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !_calcularCustoAutomaticamente,
                      decoration: const InputDecoration(
                        labelText: 'Tarifa por KM (R\$/km)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _recalcularDistanciaECusto(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _custoPesoPersonalizadoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !_calcularCustoAutomaticamente,
                      decoration: const InputDecoration(
                        labelText: 'Tarifa por KG (R\$/kg)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _recalcularDistanciaECusto(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _custoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Custo do Transporte Calculado (R\$)',
                  border: OutlineInputBorder(),
                  helperText: 'Calculado dinamicamente com base nas tarifas ativas acima',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o custo do frete.';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Digite um valor monetário válido maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _salvarViagem,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Agendar e Despachar Rota'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String cityConverter(String city) {
    return city;
  }

  void _recalcularDistanciaEPreco() {
    if (_origemSelecionada != _destinoSelecionada) {
      final distancia = DistanciaHelper.calcularDistanciaEmKm(_origemSelecionada, _destinoSelecionada);
      setState(() {
        _distanciaCalculada = distancia;
      });
      _recalcularDistanciaECusto();
    }
  }
}