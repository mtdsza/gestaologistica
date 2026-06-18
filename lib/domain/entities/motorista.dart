class Motorista {
  final int? id;
  final String nome;
  final String cnh;
  final String status;
  final int? idTransportadora;

  Motorista({
    this.id,
    required this.nome,
    required this.cnh,
    required this.status,
    this.idTransportadora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cnh': cnh,
      'status': status,
      'id_transportadora': idTransportadora,
    };
  }

  factory Motorista.fromMap(Map<String, dynamic> map) {
    return Motorista(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      cnh: map['cnh'] as String,
      status: map['status'] as String,
      idTransportadora: map['id_transportadora'] as int?,
    );
  }
}