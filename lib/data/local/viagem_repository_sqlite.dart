import 'package:gestao_logistica/data/local/database_helper.dart';
import 'package:gestao_logistica/domain/entities/viagem.dart';
import 'package:gestao_logistica/domain/repository/viagem_repository.dart';

class ViagemRepositorySqlite implements IViagemRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Viagem viagem, List<Map<String, dynamic>> itensComQuantidade) async {
    final db = await _dbHelper.database;

    // executa em bloco transacional para garantir que se uma etapa falhar, o banco seja restaurado
    await db.transaction((txn) async {
      // grava a viagem principal e recupera o id
      final viagemId = await txn.insert('viagens', viagem.toMap());

      // associa cada produto do estoque à viagem e diminui sua quantidade disponível no estoque
      for (final itemMap in itensComQuantidade) {
        final itemId = itemMap['id_item'] as int;
        final quantidade = itemMap['quantidade_transportada'] as int;

        await txn.insert('viagem_itens', {
          'id_viagem': viagemId,
          'id_item': itemId,
          'quantidade_transportada': quantidade,
        });

        await txn.execute(
          'UPDATE itens_inventario SET quantidade = quantidade - ? WHERE id = ?',
          [quantidade, itemId],
        );
      }

      // atualiza os motoristas e veículos associados para o status "em viagem"
      await txn.execute(
        "UPDATE motoristas SET status = 'Em Viagem' WHERE id = ?",
        [viagem.idMotorista],
      );
      await txn.execute(
        "UPDATE veiculos SET status = 'Em Viagem' WHERE id = ?",
        [viagem.idVeiculo],
      );
    });
  }

  @override
  Future<void> updateStatus(int id, String novoStatus) async {
    final db = await _dbHelper.database;

    // se a viagem for Concluída, o motorista e o veículo devem voltar a ficar "disponíveis"
    if (novoStatus == 'Concluido') {
      await db.transaction((txn) async {
        // busca a viagem
        final list = await txn.query('viagens', where: 'id = ?', whereArgs: [id]);
        if (list.isNotEmpty) {
          final viagemMap = list.first;
          final motoristaId = viagemMap['id_motorista'] as int;
          final veiculoId = viagemMap['id_veiculo'] as int;

          // libera o motorista e o veículo correspondentes
          await txn.execute(
            "UPDATE motoristas SET status = 'Disponivel' WHERE id = ?",
            [motoristaId],
          );
          await txn.execute(
            "UPDATE veiculos SET status = 'Disponivel' WHERE id = ?",
            [veiculoId],
          );
        }

        // atualiza o status da viagem para Concluído
        await txn.update(
          'viagens',
          {'status': novoStatus},
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } else {
      // outras transições de status
      await db.update(
        'viagens',
        {'status': novoStatus},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  @override
  Future<void> updateFaturado(int id, bool faturado) async {
    final db = await _dbHelper.database;
    await db.update(
      'viagens',
      {'faturado': faturado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Viagem>> findAll() async {
    final db = await _dbHelper.database;
    final list = await db.query('viagens');
    return list.map((map) => Viagem.fromMap(map)).toList();
  }

  @override
  Future<Viagem?> findById(int id) async {
    final db = await _dbHelper.database;
    final list = await db.query('viagens', where: 'id = ?', whereArgs: [id]);
    if (list.isNotEmpty) {
      return Viagem.fromMap(list.first);
    }
    return null;
  }

  @override
  Future<List<Viagem>> findByMotorista(int idMotorista) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'viagens',
      where: 'id_motorista = ? AND status != ?',
      whereArgs: [idMotorista, 'Concluido'],
    );
    return list.map((map) => Viagem.fromMap(map)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> findItensByViagem(int idViagem) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT vi.quantidade_transportada, ii.nome, ii.peso_unitario, ii.tipo
      FROM viagem_itens vi
      INNER JOIN itens_inventario ii ON vi.id_item = ii.id
      WHERE vi.id_viagem = ?
    ''', [idViagem]);
  }

  @override
  Future<double> getFaturamentoTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(custo_transporte) as total FROM viagens WHERE status = 'Concluido'"
    );
    final val = result.first['total'];
    return val != null ? (val as num).toDouble() : 0.0;
  }

  @override
  Future<double> getEficienciaNoPrazo() async {
    final db = await _dbHelper.database;
    
    final concluidasResult = await db.rawQuery(
      "SELECT COUNT(id) as total FROM viagens WHERE status = 'Concluido'"
    );
    final totalConcluidas = concluidasResult.first['total'] as int;
    if (totalConcluidas == 0) return 100.0;

    final totalGeralResult = await db.rawQuery("SELECT COUNT(id) as total FROM viagens");
    final totalGeral = totalGeralResult.first['total'] as int;
    if (totalGeral == 0) return 100.0;

    return (totalConcluidas / totalGeral) * 100.0;
  }

  @override
  Future<int> getViagensEmTransito() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(id) as total FROM viagens WHERE status = 'Em transito' OR status = 'Atrasado'"
    );
    return result.first['total'] as int;
  }

  @override
  Future<List<Viagem>> findHistoryByMotorista(int idMotorista) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'viagens',
      where: 'id_motorista = ?',
      whereArgs: [idMotorista],
      orderBy: 'id DESC',
    );
    return list.map((map) => Viagem.fromMap(map)).toList();
  }

  @override
  Future<List<Viagem>> findHistoryByVeiculo(int idVeiculo) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'viagens',
      where: 'id_veiculo = ?',
      whereArgs: [idVeiculo],
      orderBy: 'id DESC',
    );
    return list.map((map) => Viagem.fromMap(map)).toList();
  }
  
  @override
  Future<List<Viagem>> findHistoryByTransportadora(int idTransportadora) async {
    final db = await _dbHelper.database;
    final list = await db.query(
      'viagens',
      where: 'id_transportadora = ?',
      whereArgs: [idTransportadora],
      orderBy: 'id DESC',
    );
    return list.map((map) => Viagem.fromMap(map)).toList();
  }
}