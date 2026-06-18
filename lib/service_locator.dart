import 'package:gestao_logistica/data/local/usuario_repository_sqlite.dart';
import 'package:gestao_logistica/data/local/transportadora_repository_sqlite.dart';
import 'package:gestao_logistica/data/local/motorista_repository_sqlite.dart';
import 'package:gestao_logistica/data/local/veiculo_repository_sqlite.dart';
import 'package:gestao_logistica/data/local/item_inventario_repository_sqlite.dart';
import 'package:gestao_logistica/data/local/viagem_repository_sqlite.dart';

// define as possíveis fontes de dados
enum RepositoryType { local, memory, api }

// cria o servicelocator como singleton
class ServiceLocator {
  ServiceLocator._internal();
  static final ServiceLocator _instance = ServiceLocator._internal();
  static ServiceLocator get instance => _instance;

  // IDs de texto  para registrar e recuperar cada repositório
  static const String usuarioRepository = "usuario";
  static const String transportadoraRepository = "transportadora";
  static const String motoristaRepository = "motorista";
  static const String veiculoRepository = "veiculo";
  static const String itemInventarioRepository = "item_inventario";
  static const String viagemRepository = "viagem";

  // mapa em memória que armazena as dependências registradas
  final Map<String, dynamic> _repositories = {};

  // tipo de repositório ativo no momento (.local para usar o SQLite)
  RepositoryType repositoryType = RepositoryType.local;

  // método chamado no início do app (main.dart) para configurar o repositório correto
  void setupRepository() {
    switch (repositoryType) {
      case RepositoryType.local:
        setupConfigRepositoryLocal();
        break;
      case RepositoryType.memory:
        setupConfigRepositoryMemory();
        break;
      case RepositoryType.api:
        break;
    }
  }

  // registra as implementações físicas em SQLite no mapa de dependências
  void setupConfigRepositoryLocal() {
    _repositories[usuarioRepository] = UsuarioRepositorySqlite();
    _repositories[transportadoraRepository] = TransportadoraRepositorySqlite();
    _repositories[motoristaRepository] = MotoristaRepositorySqlite();
    _repositories[veiculoRepository] = VeiculoRepositorySqlite();
    _repositories[itemInventarioRepository] = ItemInventarioRepositorySqlite();
    _repositories[viagemRepository] = ViagemRepositorySqlite();
  }

  void setupConfigRepositoryMemory() {
  }

  // método para buscar e obter a instância do repositório desejado
  dynamic findRepository(String id) {
    if (_repositories.containsKey(id)) {
      return _repositories[id];
    }
    throw Exception("Repositório de ID '$id' não registrado no ServiceLocator.");
  }
}