import 'package:flutter/material.dart';
import 'package:gestao_logistica/domain/services/usuario_domain_services.dart';
import 'package:gestao_logistica/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // controladores de texto para capturar o conteúdo digitado
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final UsuarioDomainServices _usuarioServices = UsuarioDomainServices();

  bool _carregando = false;

  @override
  void dispose() {
    // libera os controladores da memória quando a tela for fechada
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submeterFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    final sucesso = await _usuarioServices.autenticar(
      _usuarioController.text,
      _senhaController.text,
    );

    setState(() {
      _carregando = false;
    });

    if (sucesso) {
      // se autenticar com sucesso, verifica a permissão armazenada na sessão estática
      final usuario = UsuarioDomainServices.usuarioLogado;

      if (usuario != null) {
        if (usuario.isAdmin) {
          // se for Administrador, navega para a tela principal
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          // se for Motorista, navega direto para a tela de execução
          Navigator.pushReplacementNamed(context, AppRoutes.execucaoViagem);
        }
      }
    } else {
      // se falhar, exibe uma mensagem de erro na parte inferior da tela
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou senha incorretos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada no Sistema'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Gestão Logística',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de Usuário',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe seu usuário.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true, // oculta a senha digitada
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe sua senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submeterFormulario,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Entrar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}