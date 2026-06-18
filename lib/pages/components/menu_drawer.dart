import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/services/usuario_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // inicia o serviço de usuários para realizar o logout caso solicitado
    final usuarioServices = UsuarioDomainServices();
    final usuarioLogado = UsuarioDomainServices.usuarioLogado;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // cabeçalho do menu lateral
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gestão Logística',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Usuário: ${usuarioLogado?.username ?? "Não identificado"}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // itens do menu
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // fecha o drawer antes de navegar
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Transportadoras'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.transportadorasBusca);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Motoristas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.motoristasBusca);
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Veículos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.veiculosBusca);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Controle de Estoque'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.estoqueBusca);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Planejar Viagem'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.viagensCadastro);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Monitorar Viagens'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.viagensMonitoramento);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text('Usuários do Sistema'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.usuariosBusca);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              // executa o logout e retorna para a tela de login
              usuarioServices.deslogar();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}