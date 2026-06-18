import 'package:flutter/material.dart';
import 'package:gestao_logistica/pages/login_page.dart';
import 'package:gestao_logistica/pages/home_page.dart';
import 'package:gestao_logistica/pages/transportadora_page.dart';
import 'package:gestao_logistica/pages/search_transportadora_page.dart';
import 'package:gestao_logistica/pages/motorista_page.dart';
import 'package:gestao_logistica/pages/search_motorista_page.dart';
import 'package:gestao_logistica/pages/veiculo_page.dart';
import 'package:gestao_logistica/pages/search_veiculo_page.dart';
import 'package:gestao_logistica/pages/item_inventario_page.dart';
import 'package:gestao_logistica/pages/search_item_inventario_page.dart';
import 'package:gestao_logistica/pages/viagem_page.dart';
import 'package:gestao_logistica/pages/search_viagem_page.dart';
import 'package:gestao_logistica/pages/viagem_detalhes_page.dart';
import 'package:gestao_logistica/pages/execucao_viagem_page.dart';
import 'package:gestao_logistica/pages/usuario_page.dart';
import 'package:gestao_logistica/pages/search_usuario_page.dart';

class AppRoutes {
  static const String login = "/login";
  static const String home = "/home";

  // rotas dos cruds
  static const String transportadorasBusca = "/transportadoras/busca";
  static const String transportadorasCadastro = "/transportadoras/cadastro";
  static const String motoristasBusca = "/motoristas/busca";
  static const String motoristasCadastro = "/motoristas/cadastro";
  static const String veiculosBusca = "/veiculos/busca";
  static const String veiculosCadastro = "/veiculos/cadastro";
  static const String estoqueBusca = "/estoque/busca";
  static const String estoqueCadastro = "/estoque/cadastro";
  static const String viagensCadastro = "/viagens/cadastro";
  static const String viagensMonitoramento = "/viagens/monitoramento";
  static const String execucaoViagem = "/motorista/viagem";
  static const String viagemDetalhes = "/viagens/detalhes";
  static const String usuariosBusca = "/usuarios/busca";
  static const String usuariosCadastro = "/usuarios/cadastro";

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    
    transportadorasBusca: (context) => const SearchTransportadoraPage(),
    transportadorasCadastro: (context) => const TransportadoraPage(),

    motoristasBusca: (context) => const SearchMotoristaPage(),
    motoristasCadastro: (context) => const MotoristaPage(),

    veiculosBusca: (context) => const SearchVeiculoPage(),
    veiculosCadastro: (context) => const VeiculoPage(),

    estoqueBusca: (context) => const SearchItemInventarioPage(),
    estoqueCadastro: (context) => const ItemInventarioPage(),

    viagensCadastro: (context) => const ViagemPage(),
    viagensMonitoramento: (context) => const SearchViagemPage(),
    viagemDetalhes: (context) => const ViagemDetalhesPage(),
    execucaoViagem: (context) => const ExecucaoViagemPage(),
    
    usuariosBusca: (context) => const SearchUsuarioPage(),
    usuariosCadastro: (context) => const UsuarioPage(),
  };
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'A tela "$title" está na nossa fila de desenvolvimento para as próximas fases.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}