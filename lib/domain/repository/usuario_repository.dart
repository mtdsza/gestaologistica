import 'package:gestao_logistica/domain/entities/usuario.dart';

abstract class IUsuarioRepository {
  Future<Usuario?> login(String username, String password);
  Future<void> insert(Usuario usuario);
  Future<List<Usuario>> findAll();
  Future<void> updateAtivo(int id, bool ativo);
}