import 'package:gestao_logistica/domain/entities/usuario.dart';
import 'package:gestao_logistica/domain/repository/usuario_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class UsuarioDomainServices {
  final IUsuarioRepository _usuarioRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.usuarioRepository);

  // variável que guarda os dados de quem está conectado no app.
  static Usuario? _usuarioLogado;
  // getter público para que qualquer tela do sistema possa consultar o usuário ativo
  static Usuario? get usuarioLogado => _usuarioLogado;

  Future<bool> autenticar(String username, String password) async {
    final usuario = await _usuarioRepository.login(username, password);
    if (usuario != null) {
      _usuarioLogado = usuario;
      return true;
    }
    return false;
  }

  void deslogar() {
    _usuarioLogado = null;
  }
}