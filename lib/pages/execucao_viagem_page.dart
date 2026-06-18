import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/services/usuario_domain_services.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

class ExecucaoViagemPage extends StatefulWidget {
  const ExecucaoViagemPage({super.key});

  @override
  State<ExecucaoViagemPage> createState() => _ExecucaoViagemPageState();
}

class _ExecucaoViagemPageState extends State<ExecucaoViagemPage> {
  final _viagemServices = ViagemDomainServices();
  final _usuarioServices = UsuarioDomainServices();

  Viagem? _viagemAtiva;
  List<Map<String, dynamic>> _itensCarga = [];
  
  bool _carregando = true;
  bool _simulando = false;
  String _mensagemSimulacao = '';

  @override
  void initState() {
    super.initState();
    _buscarViagemDoMotorista();
  }

  Future<void> _buscarViagemDoMotorista() async {
    final usuarioLogado = UsuarioDomainServices.usuarioLogado;

    if (usuarioLogado != null && usuarioLogado.idMotorista != null) {
      // Busca apenas as viagens ativas (não concluídas) do motorista logado
      final viagens = await _viagemServices.findByMotorista(usuarioLogado.idMotorista!);
      
      if (viagens.isNotEmpty) {
        _viagemAtiva = viagens.first;
        final itens = await _viagemServices.findItensByViagem(_viagemAtiva!.id!);
        setState(() {
          _itensCarga = itens;
          _viagemAtiva = _viagemAtiva;
        });
      } else {
        _viagemAtiva = null;
        _itensCarga = [];
      }
    }

    setState(() {
      _carregando = false;
    });
  }

  // exibe historico de rotas do motorista logado
  void _exibirHistoricoPessoal(BuildContext context) {
    final usuarioLogado = UsuarioDomainServices.usuarioLogado;
    if (usuarioLogado == null || usuarioLogado.idMotorista == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Meu Histórico de Viagens'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<List<Viagem>>(
              future: _viagemServices.findHistoryByMotorista(usuarioLogado.idMotorista!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar histórico.'));
                }

                final viagens = snapshot.data ?? [];
                if (viagens.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma viagem registrada no seu histórico.', textAlign: TextAlign.center),
                  );
                }

                return ListView.builder(
                  itemCount: viagens.length,
                  itemBuilder: (context, index) {
                    final rota = viagens[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: Text('${rota.origem} ➔ ${rota.destino}'),
                        subtitle: Text('Data: ${rota.dataPlanejada} | Status: ${rota.status}'),
                        trailing: Text('R\$ ${rota.custoTransporte.toStringAsFixed(2)}'),
                      ),
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

  // simulação de rota de entrega
  Future<void> _iniciarSimulacaoGps() async {
    if (_viagemAtiva == null) return;

    setState(() {
      _simulando = true;
      _mensagemSimulacao = 'Saindo da garagem de distribuição...';
    });

    await _viagemServices.updateStatus(_viagemAtiva!.id!, 'Em transito');
    _atualizarStatusLocal('Em transito');
    _exibirAlerta('Iniciando transporte. Rota em trânsito no GPS.');

    await Future.delayed(const Duration(seconds: 8));
    if (!mounted) return;

    await _viagemServices.updateStatus(_viagemAtiva!.id!, 'Atrasado');
    _atualizarStatusLocal('Atrasado');
    setState(() {
      _mensagemSimulacao = 'Aviso: Desvio de rota ou tráfego pesado detectado!';
    });
    _exibirAlerta('Alerta: Possível atraso detectado por desvio de tráfego.');

    await Future.delayed(const Duration(seconds: 8));
    if (!mounted) return;

    await _viagemServices.updateStatus(_viagemAtiva!.id!, 'Concluido');
    _exibirAlerta('Entrega efetuada. Viagem concluída com sucesso!');

    setState(() {
      _simulando = false;
      _mensagemSimulacao = '';
    });

    await _buscarViagemDoMotorista();
  }

  void _atualizarStatusLocal(String novoStatus) {
    if (_viagemAtiva != null) {
      setState(() {
        _viagemAtiva = Viagem(
          id: _viagemAtiva!.id,
          idMotorista: _viagemAtiva!.idMotorista,
          idVeiculo: _viagemAtiva!.idVeiculo,
          idTransportadora: _viagemAtiva!.idTransportadora,
          origem: _viagemAtiva!.origem,
          destino: _viagemAtiva!.destino,
          custoTransporte: _viagemAtiva!.custoTransporte,
          status: novoStatus,
          pesoTotal: _viagemAtiva!.pesoTotal,
          dataPlanejada: _viagemAtiva!.dataPlanejada,
          faturado: _viagemAtiva!.faturado,
        );
      });
    }
  }

  void _exibirAlerta(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _realizarLogout() {
    _usuarioServices.deslogar();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Color _obterCorStatus(String status) {
    switch (status) {
      case 'Pendente':
        return Colors.grey;
      case 'Em transito':
        return Colors.orange;
      case 'Atrasado':
        return Colors.red;
      case 'Concluido':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
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
        title: const Text('Execução de Rota'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _exibirHistoricoPessoal(context),
            icon: const Icon(Icons.history),
            tooltip: 'Meu Histórico de Viagens',
          ),
          IconButton(
            onPressed: _realizarLogout,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair do Sistema',
          ),
        ],
      ),
      body: _viagemAtiva == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Nenhuma rota ativa ou pendente designada a você no momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sua Rota de Trabalho',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${_viagemAtiva?.origem} ➔ ${_viagemAtiva?.destino}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status da Carga:'),
                              Text(
                                _viagemAtiva!.status.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _obterCorStatus(_viagemAtiva!.status),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mercadorias Carregadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _itensCarga.isEmpty
                      ? const Center(child: Text('Nenhum item associado.'))
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
                                trailing: Text(
                                  '${item['quantidade_transportada']} un',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                  
                  if (_simulando)
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              _mensagemSimulacao,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Simulando tráfego e telemetria via GPS...',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  if (!_simulando && _viagemAtiva!.status == 'Pendente')
                    ElevatedButton(
                      onPressed: _iniciarSimulacaoGps,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Iniciar Transporte'),
                    ),
                ],
              ),
            ),
    );
  }
}