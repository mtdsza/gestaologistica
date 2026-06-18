class Viagem {
  final int? id;
  final int idMotorista;
  final int idVeiculo;
  final int? idTransportadora;
  final String origem;
  final String destino;
  final double custoTransporte;
  final String status;
  final double pesoTotal;
  final String dataPlanejada;
  final bool faturado;

  Viagem({
    this.id,
    required this.idMotorista,
    required this.idVeiculo,
    this.idTransportadora,
    required this.origem,
    required this.destino,
    required this.custoTransporte,
    required this.status,
    required this.pesoTotal,
    required this.dataPlanejada,
    required this.faturado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_motorista': idMotorista,
      'id_veiculo': idVeiculo,
      'id_transportadora': idTransportadora,
      'origem': origem,
      'destino': destino,
      'custo_transporte': custoTransporte,
      'status': status,
      'peso_total': pesoTotal,
      'data_planejada': dataPlanejada,
      'faturado': faturado ? 1 : 0,
    };
  }

  factory Viagem.fromMap(Map<String, dynamic> map) {
    return Viagem(
      id: map['id'] as int?,
      idMotorista: map['id_motorista'] as int,
      idVeiculo: map['id_veiculo'] as int,
      idTransportadora: map['id_transportadora'] as int?,
      origem: map['origem'] as String,
      destino: map['destino'] as String,
      custoTransporte: (map['custo_transporte'] as num).toDouble(),
      status: map['status'] as String,
      pesoTotal: (map['peso_total'] as num).toDouble(),
      dataPlanejada: map['data_planejada'] as String,
      faturado: (map['faturado'] as int) == 1,
    );
  }
}