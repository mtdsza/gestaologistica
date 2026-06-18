import 'dart:convert'; // biblioteca nativa do dart para codificação UTF-8
import 'package:crypto/crypto.dart'; // importação do pacote de criptografia

class CriptografiaHelper {
  // salt estático
  static const String _salt = "salt_7gd@19f#g917f";

  // implementação do algoritmo SHA-256 para criptografar as senhas
  static String encriptar(String senha) {
    final textoComSalt = _salt + senha;
    final bytes = utf8.encode(textoComSalt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}