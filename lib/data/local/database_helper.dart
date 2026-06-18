import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gestao_logistica/core/criptografia_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestao_logistica.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // transportadoras
    await db.execute('''
      CREATE TABLE transportadoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cnpj TEXT UNIQUE NOT NULL,
        nome_fantasia TEXT NOT NULL,
        custo_km REAL NOT NULL DEFAULT 3.00, -- Adicionado: Custo por quilômetro
        custo_peso REAL NOT NULL DEFAULT 0.15 -- Adicionado: Custo por quilograma
      )
    ''');

    // motoristas
    await db.execute('''
      CREATE TABLE motoristas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cnh TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL DEFAULT 'Disponivel',
        id_transportadora INTEGER NULL,
        FOREIGN KEY (id_transportadora) REFERENCES transportadoras (id) ON DELETE SET NULL,
        CHECK (status IN ('Disponivel', 'Em Viagem', 'Inativo'))
      )
    ''');

    // veiculos
    await db.execute('''
      CREATE TABLE veiculos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        placa TEXT UNIQUE NOT NULL,
        tipo TEXT NOT NULL,
        capacidade_carga REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Disponivel',
        id_transportadora INTEGER NULL,
        FOREIGN KEY (id_transportadora) REFERENCES transportadoras (id) ON DELETE SET NULL,
        CHECK (tipo IN ('Carreta', 'Caminhao Bau', 'Fiorino')),
        CHECK (status IN ('Disponivel', 'Manutencao', 'Em Viagem'))
      )
    ''');

    // itens do estoque
    await db.execute('''
      CREATE TABLE itens_inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        peso_unitario REAL NOT NULL,
        quantidade INTEGER NOT NULL DEFAULT 0,
        cidade TEXT NOT NULL,
        data_validade TEXT NULL,
        localizacao TEXT NULL,
        CHECK (tipo IN ('Perecivel', 'Eletronico', 'Fragil', 'Geral')),
        CHECK (peso_unitario > 0),
        CHECK (quantidade >= 0)
      )
    ''');

    // usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        is_admin INTEGER NOT NULL DEFAULT 1,
        id_motorista INTEGER NULL,
        ativo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_motorista) REFERENCES motoristas (id) ON DELETE SET NULL
      )
    ''');

    // viagens
    await db.execute('''
      CREATE TABLE viagens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_motorista INTEGER NOT NULL,
        id_veiculo INTEGER NOT NULL,
        id_transportadora INTEGER NULL,
        origem TEXT NOT NULL,
        destino TEXT NOT NULL,
        custo_transporte REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pendente',
        peso_total REAL NOT NULL DEFAULT 0.0,
        data_planejada TEXT NOT NULL,
        faturado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id_motorista) REFERENCES motoristas (id) ON DELETE RESTRICT,
        FOREIGN KEY (id_veiculo) REFERENCES veiculos (id) ON DELETE RESTRICT,
        FOREIGN KEY (id_transportadora) REFERENCES transportadoras (id) ON DELETE SET NULL,
        CHECK (status IN ('Pendente', 'Em transito', 'Atrasado', 'Concluido')),
        CHECK (faturado IN (0, 1))
      )
    ''');

    // viagem_itens
    await db.execute('''
      CREATE TABLE viagem_itens (
        id_viagem INTEGER NOT NULL,
        id_item INTEGER NOT NULL,
        quantidade_transportada INTEGER NOT NULL,
        PRIMARY KEY (id_viagem, id_item),
        FOREIGN KEY (id_viagem) REFERENCES viagens (id) ON DELETE CASCADE,
        FOREIGN KEY (id_item) REFERENCES itens_inventario (id) ON DELETE RESTRICT
      )
    ''');

    await _insertSeeds(db);
  }

  Future<void> _insertSeeds(Database db) async {
    // insere transportadoras
    await db.rawInsert("INSERT INTO transportadoras (id, cnpj, nome_fantasia, custo_km, custo_peso) VALUES (1, '11111111000100', 'Rapido Curitiba', 3.20, 0.12)");
    await db.rawInsert("INSERT INTO transportadoras (id, cnpj, nome_fantasia, custo_km, custo_peso) VALUES (2, '22222222000100', 'Paulista Cargas', 3.80, 0.18)");
    await db.rawInsert("INSERT INTO transportadoras (id, cnpj, nome_fantasia, custo_km, custo_peso) VALUES (3, '33333333000100', 'Minas Cargas', 2.90, 0.10)");

    // insere motoristas
    await db.rawInsert("INSERT INTO motoristas (id, nome, cnh, status, id_transportadora) VALUES (1, 'Joao da Silva (Frota Propria)', '12345678900', 'Disponivel', NULL)");
    await db.rawInsert("INSERT INTO motoristas (id, nome, cnh, status, id_transportadora) VALUES (2, 'Carlos Curitibano', '11111111111', 'Disponivel', 1)");
    await db.rawInsert("INSERT INTO motoristas (id, nome, cnh, status, id_transportadora) VALUES (3, 'Pedro Paulista', '22222222222', 'Disponivel', 2)");
    await db.rawInsert("INSERT INTO motoristas (id, nome, cnh, status, id_transportadora) VALUES (4, 'Lucas Mineiro', '33333333333', 'Disponivel', 3)");

    // criptografa as senhas
    final senhaAdmin = CriptografiaHelper.encriptar('admin123');
    final senhaMotorista = CriptografiaHelper.encriptar('motorista123');

    // insere logins, incluindo os dos motoristas
    await db.rawInsert("INSERT INTO usuarios (username, password, is_admin, id_motorista) VALUES ('admin', '$senhaAdmin', 1, NULL)");
    await db.rawInsert("INSERT INTO usuarios (username, password, is_admin, id_motorista) VALUES ('joao', '$senhaMotorista', 0, 1)");
    await db.rawInsert("INSERT INTO usuarios (username, password, is_admin, id_motorista) VALUES ('carlos', '$senhaMotorista', 0, 2)");
    await db.rawInsert("INSERT INTO usuarios (username, password, is_admin, id_motorista) VALUES ('pedro', '$senhaMotorista', 0, 3)");
    await db.rawInsert("INSERT INTO usuarios (username, password, is_admin, id_motorista) VALUES ('lucas', '$senhaMotorista', 0, 4)");

    // insere veiculos
    await db.rawInsert("INSERT INTO veiculos (id, placa, tipo, capacidade_carga, status, id_transportadora) VALUES (1, 'ABC-1234', 'Fiorino', 500.0, 'Disponivel', NULL)");
    await db.rawInsert("INSERT INTO veiculos (id, placa, tipo, capacidade_carga, status, id_transportadora) VALUES (2, 'XYZ-5678', 'Caminhao Bau', 5000.0, 'Disponivel', NULL)");
    await db.rawInsert("INSERT INTO veiculos (id, placa, tipo, capacidade_carga, status, id_transportadora) VALUES (3, 'PRC-1000', 'Caminhao Bau', 4000.0, 'Disponivel', 1)");
    await db.rawInsert("INSERT INTO veiculos (id, placa, tipo, capacidade_carga, status, id_transportadora) VALUES (4, 'SPC-2000', 'Carreta', 15000.0, 'Disponivel', 2)");
    await db.rawInsert("INSERT INTO veiculos (id, placa, tipo, capacidade_carga, status, id_transportadora) VALUES (5, 'MGC-3000', 'Fiorino', 600.0, 'Disponivel', 3)");

    // insere itens de estoque, em vários centros de distribuição
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Televisor LED 55', 'Eletronico', 15.0, 100, 'Sao Paulo', NULL, 'Setor A - Prateleira 12')"
    );
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Leite Condensado CX', 'Perecivel', 0.4, 1000, 'Sao Paulo', '2026-05-15', 'Câmara Fria 2 - Setor Sul')"
    );
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Iogurte Natural CX', 'Perecivel', 0.2, 500, 'Sao Paulo', '2026-08-30', 'Câmara Fria 1 - Setor Norte')"
    );
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Cimento Saco 50kg', 'Geral', 50.0, 200, 'Curitiba', NULL, 'Galpão Externo - Setor C')"
    );
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Pneu de Caminhao', 'Geral', 80.0, 50, 'Curitiba', NULL, 'Estoque Central de Pneus')"
    );
    await db.rawInsert(
      "INSERT INTO itens_inventario (nome, tipo, peso_unitario, quantidade, cidade, data_validade, localizacao) VALUES ('Cafe Gourmet Moido', 'Geral', 0.5, 300, 'Belo Horizonte', NULL, 'Prateleira Grãos Minas 2')"
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}