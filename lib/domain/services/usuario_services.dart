import 'package:gestao_logistica/domain/entities/usuario.dart';
import 'package:gestao_logistica/domain/repository/usuario_repository.dart';
import 'package:gestao_logistica/service_locator.dart';

class UsuarioServices {
  final IUsuarioRepository _usuarioRepository =
      ServiceLocator.instance.findRepository(ServiceLocator.usuarioRepository);

  Future<void> insert(Usuario usuario) async {
    await _usuarioRepository.insert(usuario);
  }

  Future<List<Usuario>> findAll() async {
    return await _usuarioRepository.findAll();
  }

  Future<void> updateAtivo(int id, bool ativo) async {
    await _usuarioRepository.updateAtivo(id, ativo);
  }
}