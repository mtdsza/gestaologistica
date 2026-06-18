import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/motorista_domain_services.dart';
import 'package:gestao_logistica/domain/services/veiculo_domain_services.dart';
import 'package:gestao_logistica/domain/services/transportadora_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';

class ViagemDetalhesPage extends StatefulWidget {
  const ViagemDetalhesPage({super.key});

  @override
  State<ViagemDetalhesPage> createState() => _ViagemDetalhesPageState();
}

class _ViagemDetalhesPageState extends State<ViagemDetalhesPage> {
  final _viagemServices = ViagemDomainServices();
  final _motoristaServices = MotoristaDomainServices();
  final _veiculoServices = VeiculoDomainServices();
  final _transportadoraServices = TransportadoraDomainServices();

  Viagem? _viagem;
  String _motoristaNome = '';
  String _veiculoPlaca = '';
  String _transportadoraNome = 'Frota Própria (Interno)';
  List<Map<String, dynamic>> _itensCarga = [];
  bool _carregando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viagem == null) {
      _viagem = ModalRoute.of(context)!.settings.arguments as Viagem;
      _carregarDados();
    }
  }

  Future<void> _carregarDados() async {
    final motorista = await _motoristaServices.findById(_viagem!.idMotorista);
    final veiculo = await _veiculoServices.findById(_viagem!.idVeiculo);
    final itens = await _viagemServices.findItensByViagem(_viagem!.id!);

    // carrega o nome da transportadora se houver vínculo na viagem
    if (_viagem!.idTransportadora != null) {
      final transportadora = await _transportadoraServices.findById(_viagem!.idTransportadora!);
      if (transportadora != null) {
        _transportadoraNome = transportadora.nomeFantasia;
      }
    }

    setState(() {
      _motoristaNome = motorista?.nome ?? 'Não encontrado';
      _veiculoPlaca = veiculo != null ? '${veiculo.tipo} (${veiculo.placa})' : 'Não encontrado';
      _itensCarga = itens;
      _carregando = false;
    });
  }

  Future<void> _faturarViagem() async {
    if (_viagem == null) return;

    await _viagemServices.updateFaturado(_viagem!.id!, true);
    final viagemAtualizada = await _viagemServices.findById(_viagem!.id!);

    setState(() {
      _viagem = viagemAtualizada;
    });

    _exibirNotaFiscal();
  }

  void _exibirNotaFiscal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nota Fiscal de Serviço de Transporte'),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                color: Colors.yellow[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DADOS DO EMISSOR:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const Text('CENTRO DE DISTRIBUIÇÃO LOGÍSTICA S.A.'),
                  const Text('CNPJ: 00.000.000/0001-00'),
                  const Divider(),
                  const Text('TRANSPORTADORA OPERADORA:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_transportadoraNome.toUpperCase()),
                  const Divider(),
                  const Text('DADOS DO FRETE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Origem: ${_viagem?.origem}'),
                  Text('Destino: ${_viagem?.destino}'),
                  Text('Motorista: $_motoristaNome'),
                  Text('Veículo: $_veiculoPlaca'),
                  const Divider(),
                  const Text('ITENS TRANSPORTADOS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ..._itensCarga.map((item) {
                    return Text(
                      '- ${item['nome']} (Qtd: ${item['quantidade_transportada']} un | Cat: ${item['tipo']})',
                      style: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                  const Divider(),
                  Text('Peso Total da Carga: ${_viagem?.pesoTotal.toStringAsFixed(1)} kg'),
                  Text(
                    'VALOR TOTAL DO SERVIÇO: R\$ ${_viagem?.custoTransporte.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
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
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhamento da Viagem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Gerais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.navigation),
                      title: const Text('Rota'),
                      subtitle: Text('${_viagem?.origem} ➔ ${_viagem?.destino}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Transportadora Responsável'),
                      subtitle: Text(_transportadoraNome),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Motorista Encarregado'),
                      subtitle: Text(_motoristaNome),
                    ),
                    ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: const Text('Veículo Utilizado'),
                      subtitle: Text(_veiculoPlaca),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Carga e Mercadorias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _itensCarga.isEmpty
                ? const Center(child: Text('Nenhum item associado a esta viagem.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _itensCarga.length,
                    itemBuilder: (context, index) {
                      final item = _itensCarga[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(item['nome']),
                          subtitle: Text('Categoria: ${item['tipo']} | Peso Unit.: ${item['peso_unitario']} kg'),
                          trailing: Text(
                            '${item['quantidade_transportada']} un',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            const Text(
              'Faturamento e Custos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Custo de Transporte:'),
                        Text(
                          'R\$ ${_viagem?.custoTransporte.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Peso Total Calculado:'),
                        Text(
                          '${_viagem?.pesoTotal.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Situação de Faturamento:'),
                        Text(
                          _viagem!.faturado ? 'Faturado / Nota Emitida' : 'Pendente de Emissão',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _viagem!.faturado ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _viagem!.faturado ? _exibirNotaFiscal : _faturarViagem,
              style: ElevatedButton.styleFrom(
                backgroundColor: _viagem!.faturado ? Colors.green : Colors.blue,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(_viagem!.faturado ? 'Visualizar Nota Fiscal' : 'Faturar e Emitir Nota Fiscal'),
            ),
          ],
        ),
      ),
    );
  }
}