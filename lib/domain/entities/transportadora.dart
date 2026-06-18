class Transportadora {
  final int? id;
  final String cnpj;
  final String nomeFantasia;
  final double custoKm;
  final double custoPeso;

  Transportadora({
    this.id,
    required this.cnpj,
    required this.nomeFantasia,
    this.custoKm = 3.00,
    this.custoPeso = 0.15,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cnpj': cnpj,
      'nome_fantasia': nomeFantasia,
      'custo_km': custoKm,
      'custo_peso': custoPeso,
    };
  }

  factory Transportadora.fromMap(Map<String, dynamic> map) {
    return Transportadora(
      id: map['id'] as int?,
      cnpj: map['cnpj'] as String,
      nomeFantasia: map['nome_fantasia'] as String,
      custoKm: (map['custo_km'] as num?)?.toDouble() ?? 3.00,
      custoPeso: (map['custo_peso'] as num?)?.toDouble() ?? 0.15,
    );
  }
}