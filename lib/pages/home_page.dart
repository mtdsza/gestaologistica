import 'package:flutter/material.dart';
import 'package:gestao_logistica/pages/components/menu_drawer.dart';
import 'package:gestao_logistica/domain/services/viagem_domain_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _viagemServices = ViagemDomainServices();

  double _faturamentoTotal = 0.0;
  double _eficienciaNoPrazo = 100.0;
  int _viagensEmAndamento = 0;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarIndicadores();
  }

  // busca os indicadores estatísticos
  Future<void> _carregarIndicadores() async {
    final faturamento = await _viagemServices.getFaturamentoTotal();
    final eficiencia = await _viagemServices.getEficienciaNoPrazo();
    final emAndamento = await _viagemServices.getViagensEmTransito();

    setState(() {
      _faturamentoTotal = faturamento;
      _eficienciaNoPrazo = eficiencia;
      _viagensEmAndamento = emAndamento;
      _carregando = false;
    });
  }

  Widget _buildCardIndicador({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color corIcone,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: corIcone.withOpacity(0.1),
              radius: 24,
              child: Icon(icone, color: corIcone, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Controle'),
        actions: [
          // botão para atualizar manualmente os números da dashboard
          IconButton(
            onPressed: () {
              setState(() {
                _carregando = true;
              });
              _carregarIndicadores();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Dados',
          )
        ],
      ),
      // vincula o menu lateral do sistema
      drawer: const MenuDrawer(),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarIndicadores,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Indicadores Logísticos em Tempo Real',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // faturamento de fretes concluídos
                  _buildCardIndicador(
                    titulo: 'Faturamento de Fretes Concluídos',
                    valor: 'R\$ ${_faturamentoTotal.toStringAsFixed(2)}',
                    icone: Icons.attach_money,
                    corIcone: Colors.green,
                  ),

                  // eficiência operacional
                  _buildCardIndicador(
                    titulo: 'Eficiência de Entregas',
                    valor: '${_eficienciaNoPrazo.toStringAsFixed(1)}%',
                    icone: Icons.assignment_turned_in,
                    corIcone: Colors.blue,
                  ),

                  // rotas ativas
                  _buildCardIndicador(
                    titulo: 'Rotas Ativas em Trânsito',
                    valor: '$_viagensEmAndamento',
                    icone: Icons.local_shipping,
                    corIcone: Colors.orange,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Para gerenciar cadastros, planejar novas viagens ou emitir notas fiscais, '
                    'utilize o menu lateral no canto superior esquerdo da tela.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}