class Veiculo {
  final int? id;
  final String placa;
  final String tipo;
  final double capacidadeCarga;
  final String status;
  final int? idTransportadora;

  Veiculo({
    this.id,
    required this.placa,
    required this.tipo,
    required this.capacidadeCarga,
    required this.status,
    this.idTransportadora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placa': placa,
      'tipo': tipo,
      'capacidade_carga': capacidadeCarga,
      'status': status,
      'id_transportadora': idTransportadora,
    };
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      id: map['id'] as int?,
      placa: map['placa'] as String,
      tipo: map['tipo'] as String,
      capacidadeCarga: (map['capacidade_carga'] as num).toDouble(),
      status: map['status'] as String,
      idTransportadora: map['id_transportadora'] as int?,
    );
  }
}