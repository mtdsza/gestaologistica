import 'dart:io'; // biblioteca padrão para identificar o sistema operacional
import 'package:flutter/material.dart';
import 'package:gestao_logistica/routes.dart';
import 'package:gestao_logistica/service_locator.dart';
import 'package:sqflite/sqflite.dart'; // biblioteca do banco SQLite
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // dá suporte aos bancos SQLite em plataformas desktop

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // verifica se o aplicativo está rodando em um sistema desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // inicializa o carregador ffi do sqlite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // inicializa o ServiceLocator, registrando os repositórios locais
  ServiceLocator.instance.setupRepository();

  runApp(const MainApp());
}
// configuração global da interface
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão Logística',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}