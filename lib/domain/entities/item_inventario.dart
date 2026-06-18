class ItemInventario {
  final int? id;
  final String nome;
  final String tipo;
  final double pesoUnitario;
  final int quantidade;
  final String cidade;
  final String? dataValidade;
  final String? localizacao;

  ItemInventario({
    this.id,
    required this.nome,
    required this.tipo,
    required this.pesoUnitario,
    required this.quantidade,
    required this.cidade,
    this.dataValidade,
    this.localizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'peso_unitario': pesoUnitario,
      'quantidade': quantidade,
      'cidade': cidade,
      'data_validade': dataValidade,
      'localizacao': localizacao,
    };
  }

  factory ItemInventario.fromMap(Map<String, dynamic> map) {
    return ItemInventario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      pesoUnitario: (map['peso_unitario'] as num).toDouble(),
      quantidade: map['quantidade'] as int,
      cidade: map['cidade'] as String,
      dataValidade: map['data_validade'] as String?,
      localizacao: map['localizacao'] as String?,
    );
  }
}