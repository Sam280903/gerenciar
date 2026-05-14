// test/estresse/estresse_test.dart
// Testes de estresse para validar o sistema sob carga pesada
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/cadastrar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/cadastrar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/listar_agendamentos.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dados/modelos/ordem_servico_model.dart';
import 'package:gerenciar/dados/modelos/cliente_model.dart';
import 'package:gerenciar/dados/modelos/agendamento_model.dart';
import 'package:gerenciar/dados/modelos/tecnico_model.dart';
import 'package:gerenciar/dados/modelos/forma_pagamento_model.dart';
import '../helpers/cliente_repositorio_memoria.dart';
import '../helpers/tecnico_repositorio_memoria.dart';
import '../helpers/agendamento_repositorio_memoria.dart';
import '../helpers/ordem_servico_repositorio_memoria.dart';
import '../helpers/forma_pagamento_repositorio_memoria.dart';

const _idGestor = 'gestor-stress';
const _volume = 1000; // registros por entidade

void main() {
  // ═══════════════════════════════════════════════════════════════
  // GRUPO 1: ESTRESSE DE VOLUME — Repositórios em Memória
  // Simula a mesma lógica que SQLite/Firebase usam
  // ═══════════════════════════════════════════════════════════════
  group('Estresse de Volume — Clientes ($_volume registros)', () {
    late ClienteRepositorioMemoria repo;
    late CadastrarCliente cadastrar;
    late ListarClientes listar;

    setUp(() {
      repo = ClienteRepositorioMemoria();
      cadastrar = CadastrarCliente(repo);
      listar = ListarClientes(repo);
    });

    test('Inserir $_volume clientes em sequência', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(Cliente(
          id: 'cli-$i', nome: 'Cliente $i', email: 'c$i@test.com',
          telefone: '(62) 9$i', endereco: 'Rua $i', ativo: true,
          idGestor: _idGestor,
        ));
      }
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, _volume);
      // ignore: avoid_print
      print('  ⏱ Inserção de $_volume clientes: ${sw.elapsedMilliseconds}ms');
    });

    test('Listar $_volume clientes com filtro de gestor', () async {
      // Prepara dados: metade gestor A, metade gestor B
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(Cliente(
          id: 'cli-$i', nome: 'Cliente $i', email: 'c$i@test.com',
          telefone: '(62) 9$i', endereco: 'Rua $i', ativo: true,
          idGestor: i < _volume ~/ 2 ? _idGestor : 'outro-gestor',
        ));
      }
      final sw = Stopwatch()..start();
      final lista = await listar.executar(idGestor: _idGestor);
      sw.stop();
      expect(lista.length, _volume ~/ 2);
      // ignore: avoid_print
      print('  ⏱ Filtragem de ${_volume ~/ 2} clientes: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Volume — Técnicos ($_volume registros)', () {
    late TecnicoRepositorioMemoria repo;
    late CadastrarTecnico cadastrar;
    late ListarTecnicos listar;

    setUp(() {
      repo = TecnicoRepositorioMemoria();
      cadastrar = CadastrarTecnico(repo);
      listar = ListarTecnicos(repo);
    });

    test('Inserir $_volume técnicos em sequência', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(Tecnico(
          id: 'tec-$i', nome: 'Técnico $i', email: 't$i@test.com',
          telefone: '(62) 8$i', ativo: true, idGestor: _idGestor,
        ));
      }
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, _volume);
      // ignore: avoid_print
      print('  ⏱ Inserção de $_volume técnicos: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Volume — Ordens de Serviço ($_volume registros)', () {
    late OrdemServicoRepositorioMemoria repo;
    late CadastrarOrdemServico cadastrar;
    late ListarOrdensServico listar;

    setUp(() {
      repo = OrdemServicoRepositorioMemoria();
      cadastrar = CadastrarOrdemServico(repo);
      listar = ListarOrdensServico(repo);
    });

    test('Inserir $_volume OS em sequência', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(OrdemServico(
          id: 'os-$i', idTecnico: 'tec-${i % 10}', idCliente: 'cli-${i % 50}',
          idFormaPagamento: 'fp-${i % 5}', idGestor: _idGestor,
          dataHoraInicio: DateTime(2026, 1, 1).add(Duration(hours: i)),
          descricao: 'OS de estresse #$i', valor: 150.0 + i,
          prioridade: ['Baixa', 'Média', 'Alta'][i % 3],
          status: 'Pendente', ativo: true,
        ));
      }
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, _volume);
      // ignore: avoid_print
      print('  ⏱ Inserção de $_volume OS: ${sw.elapsedMilliseconds}ms');
    });

    test('Inativar e listar mantém consistência', () async {
      for (int i = 0; i < 500; i++) {
        await cadastrar.executar(OrdemServico(
          id: 'os-$i', idTecnico: 'tec-0', idCliente: 'cli-0',
          idFormaPagamento: 'fp-0', idGestor: _idGestor,
          dataHoraInicio: DateTime(2026, 1, 1).add(Duration(hours: i)),
          descricao: 'OS #$i', valor: 100.0, prioridade: 'Baixa',
          status: 'Pendente', ativo: true,
        ));
      }
      // Inativa metade
      for (int i = 0; i < 250; i++) {
        await repo.inativar('os-$i');
      }
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, 250);
    });
  });

  group('Estresse de Volume — Agendamentos ($_volume registros)', () {
    late AgendamentoRepositorioMemoria repo;
    late CadastrarAgendamento cadastrar;
    late ListarAgendamentos listar;

    setUp(() {
      repo = AgendamentoRepositorioMemoria();
      cadastrar = CadastrarAgendamento(repo);
      listar = ListarAgendamentos(repo);
    });

    test('Inserir $_volume agendamentos em sequência', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(Agendamento(
          id: 'ag-$i', idTecnico: 'tec-${i % 10}', idCliente: 'cli-${i % 50}',
          idGestor: _idGestor,
          dataHora: DateTime(2026, 6, 1).add(Duration(minutes: i * 30)),
        ));
      }
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, _volume);
      // ignore: avoid_print
      print('  ⏱ Inserção de $_volume agendamentos: ${sw.elapsedMilliseconds}ms');
    });

    test('Verificar disponibilidade com $_volume agendamentos', () async {
      for (int i = 0; i < _volume; i++) {
        await cadastrar.executar(Agendamento(
          id: 'ag-$i', idTecnico: 'tec-0', idCliente: 'cli-0',
          idGestor: _idGestor,
          dataHora: DateTime(2026, 6, 1).add(Duration(minutes: i * 30)),
        ));
      }
      final sw = Stopwatch()..start();
      // Verifica conflito no último horário
      final ocupado = await repo.verificarDisponibilidade(
        'tec-0',
        DateTime(2026, 6, 1).add(Duration(minutes: (_volume - 1) * 30)),
      );
      sw.stop();
      expect(ocupado, isTrue);
      // ignore: avoid_print
      print('  ⏱ Verificação em $_volume registros: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Volume — Formas de Pagamento', () {
    late FormaPagamentoRepositorioMemoria repo;
    late CadastrarFormaPagamento cadastrar;
    late ListarFormasPagamento listar;

    setUp(() {
      repo = FormaPagamentoRepositorioMemoria();
      cadastrar = CadastrarFormaPagamento(repo);
      listar = ListarFormasPagamento(repo);
    });

    test('Inserir 500 formas de pagamento', () async {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 500; i++) {
        await cadastrar.executar(FormaPagamento(
          id: 'fp-$i', nome: 'Forma $i',
          descricao: 'Descrição da forma $i',
          ativo: true, idGestor: _idGestor,
        ));
      }
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, 500);
      // ignore: avoid_print
      print('  ⏱ Inserção de 500 formas: ${sw.elapsedMilliseconds}ms');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // GRUPO 2: ESTRESSE DE SERIALIZAÇÃO — Modelos (camada Firebase/SQLite)
  // Testa a conversão rápida de/para Map (mesmo código usado em ambos)
  // ═══════════════════════════════════════════════════════════════
  group('Estresse de Serialização — OrdemServicoModel ($_volume ciclos)', () {
    test('toMap/fromDbMap em loop rápido', () {
      final model = OrdemServicoModel(
        id: 'os-1', idTecnico: 'tec-1', idCliente: 'cli-1',
        idFormaPagamento: 'fp-1', idGestor: _idGestor,
        dataHoraInicio: DateTime(2026, 1, 15, 10, 30),
        dataHoraFim: DateTime(2026, 1, 15, 12, 0),
        descricao: 'Manutenção preventiva do sistema de ar condicionado',
        valor: 350.75, prioridade: 'Alta', status: 'Concluída',
        justificativaReabertura: null, ativo: true,
      );

      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final map = model.toMapForDb();
        final restored = OrdemServicoModel.fromDbMap(map);
        expect(restored.id, model.id);
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos toMapForDb/fromDbMap: ${sw.elapsedMilliseconds}ms');
    });

    test('toEntidade/fromEntidade em loop rápido', () {
      final model = OrdemServicoModel(
        id: 'os-1', idTecnico: 'tec-1', idCliente: 'cli-1',
        idFormaPagamento: 'fp-1', idGestor: _idGestor,
        dataHoraInicio: DateTime(2026, 1, 15), descricao: 'Teste',
        valor: 200.0, prioridade: 'Média', status: 'Pendente', ativo: true,
      );

      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final entidade = model.toEntidade();
        final back = OrdemServicoModel.fromEntidade(entidade);
        expect(back.valor, model.valor);
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos entidade↔model: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Serialização — ClienteModel ($_volume ciclos)', () {
    test('toMap/fromMap em loop rápido', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final map = {
          'nome': 'Cliente $i', 'email': 'c$i@test.com',
          'telefone': '(62) 99999-$i', 'endereco': 'Rua $i, 123',
          'cpf': '123.456.789-$i', 'ativo': i % 2 == 0,
          'idGestor': _idGestor,
        };
        final model = ClienteModel.fromMap(map, 'cli-$i');
        final back = model.toMap();
        expect(back['nome'], 'Cliente $i');
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos ClienteModel: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Serialização — AgendamentoModel ($_volume ciclos)', () {
    test('toMapForDb/fromMap com tipos mistos', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final model = AgendamentoModel(
          id: 'ag-$i', idTecnico: 'tec-$i', idCliente: 'cli-$i',
          idGestor: _idGestor,
          dataHora: DateTime(2026, 6, 1).add(Duration(hours: i)),
          status: 'Pendente', notificacaoEnviada: false,
        );
        final dbMap = model.toMapForDb();
        // Simula leitura do SQLite (String para dataHora)
        final restored = AgendamentoModel.fromMap(dbMap, 'ag-$i');
        expect(restored.idTecnico, 'tec-$i');
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos AgendamentoModel: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Serialização — TecnicoModel ($_volume ciclos)', () {
    test('toMap/fromMap em loop', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final map = {
          'nome': 'Técnico $i', 'email': 't$i@test.com',
          'telefone': '(62) 8$i', 'ativo': true, 'idGestor': _idGestor,
        };
        final model = TecnicoModel.fromMap(map, 'tec-$i');
        final back = model.toMap();
        expect(back['nome'], 'Técnico $i');
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos TecnicoModel: ${sw.elapsedMilliseconds}ms');
    });
  });

  group('Estresse de Serialização — FormaPagamentoModel ($_volume ciclos)', () {
    test('toMap/fromMap em loop', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < _volume; i++) {
        final map = {
          'nome': 'Forma $i', 'descricao': 'Desc $i',
          'ativo': true, 'idGestor': _idGestor,
        };
        final model = FormaPagamentoModel.fromMap(map, 'fp-$i');
        final back = model.toMap();
        expect(back['nome'], 'Forma $i');
      }
      sw.stop();
      // ignore: avoid_print
      print('  ⏱ $_volume ciclos FormaPagamentoModel: ${sw.elapsedMilliseconds}ms');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // GRUPO 3: ESTRESSE CONCORRENTE — Operações paralelas
  // ═══════════════════════════════════════════════════════════════
  group('Estresse Concorrente — Operações paralelas', () {
    test('500 inserções simultâneas de clientes', () async {
      final repo = ClienteRepositorioMemoria();
      final cadastrar = CadastrarCliente(repo);
      final listar = ListarClientes(repo);

      final sw = Stopwatch()..start();
      await Future.wait(List.generate(500, (i) =>
        cadastrar.executar(Cliente(
          id: 'cli-$i', nome: 'Cliente $i', email: 'c$i@test.com',
          telefone: '(62) 9$i', endereco: 'Rua $i', ativo: true,
          idGestor: _idGestor,
        )),
      ));
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, 500);
      // ignore: avoid_print
      print('  ⏱ 500 inserções paralelas de clientes: ${sw.elapsedMilliseconds}ms');
    });

    test('500 inserções simultâneas de OS', () async {
      final repo = OrdemServicoRepositorioMemoria();
      final cadastrar = CadastrarOrdemServico(repo);
      final listar = ListarOrdensServico(repo);

      final sw = Stopwatch()..start();
      await Future.wait(List.generate(500, (i) =>
        cadastrar.executar(OrdemServico(
          id: 'os-$i', idTecnico: 'tec-${i % 10}', idCliente: 'cli-${i % 50}',
          idFormaPagamento: 'fp-0', idGestor: _idGestor,
          dataHoraInicio: DateTime(2026, 1, 1).add(Duration(hours: i)),
          descricao: 'OS #$i', valor: 100.0 + i, prioridade: 'Média',
          status: 'Pendente', ativo: true,
        )),
      ));
      sw.stop();
      final lista = await listar.executar(idGestor: _idGestor);
      expect(lista.length, 500);
      // ignore: avoid_print
      print('  ⏱ 500 inserções paralelas de OS: ${sw.elapsedMilliseconds}ms');
    });

    test('Leitura e escrita simultâneas (race condition)', () async {
      final repo = ClienteRepositorioMemoria();
      final cadastrar = CadastrarCliente(repo);
      final listar = ListarClientes(repo);

      // Insere 200 clientes primeiro
      for (int i = 0; i < 200; i++) {
        await cadastrar.executar(Cliente(
          id: 'cli-$i', nome: 'Cliente $i', email: 'c$i@test.com',
          telefone: '(62) 9$i', endereco: 'Rua $i', ativo: true,
          idGestor: _idGestor,
        ));
      }

      // Operações mistas simultâneas: leitura + escrita + inativação
      final sw = Stopwatch()..start();
      await Future.wait([
        // Leituras
        ...List.generate(100, (_) => listar.executar(idGestor: _idGestor)),
        // Escritas
        ...List.generate(100, (i) => cadastrar.executar(Cliente(
          id: 'cli-new-$i', nome: 'Novo $i', email: 'n$i@test.com',
          telefone: '(62) 7$i', endereco: 'Av $i', ativo: true,
          idGestor: _idGestor,
        ))),
        // Inativações
        ...List.generate(50, (i) => repo.inativar('cli-$i')),
      ]);
      sw.stop();
      final listaFinal = await listar.executar(idGestor: _idGestor);
      // 200 originais - 50 inativados + 100 novos = 250
      expect(listaFinal.length, 250);
      // ignore: avoid_print
      print('  ⏱ 250 operações mistas simultâneas: ${sw.elapsedMilliseconds}ms');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // GRUPO 4: ESTRESSE DE ISOLAMENTO — Multi-gestor
  // ═══════════════════════════════════════════════════════════════
  group('Estresse de Isolamento — Multi-gestor', () {
    test('10 gestores com 100 clientes cada, sem vazamento', () async {
      final repo = ClienteRepositorioMemoria();
      final cadastrar = CadastrarCliente(repo);
      final listar = ListarClientes(repo);

      final gestores = List.generate(10, (i) => 'gestor-$i');
      for (final gestor in gestores) {
        for (int i = 0; i < 100; i++) {
          await cadastrar.executar(Cliente(
            id: '$gestor-cli-$i', nome: 'Cliente $i de $gestor',
            email: '$gestor-$i@test.com', telefone: '(62) 9$i',
            endereco: 'Rua $i', ativo: true, idGestor: gestor,
          ));
        }
      }

      // Verifica isolamento
      for (final gestor in gestores) {
        final lista = await listar.executar(idGestor: gestor);
        expect(lista.length, 100,
          reason: 'Gestor $gestor deveria ter exatamente 100 clientes');
      }
    });

    test('5 gestores com 200 OS cada, filtros por status', () async {
      final repo = OrdemServicoRepositorioMemoria();
      final gestores = List.generate(5, (i) => 'gestor-$i');
      final status = ['Pendente', 'Em Andamento', 'Concluída', 'Reaberta'];

      for (final gestor in gestores) {
        for (int i = 0; i < 200; i++) {
          await repo.adicionar(OrdemServico(
            id: '$gestor-os-$i', idTecnico: 'tec-0', idCliente: 'cli-0',
            idFormaPagamento: 'fp-0', idGestor: gestor,
            dataHoraInicio: DateTime(2026, 1, 1).add(Duration(hours: i)),
            descricao: 'OS #$i', valor: 100.0,
            prioridade: 'Média', status: status[i % 4], ativo: true,
          ));
        }
      }

      // Verifica que cada gestor tem 200 OS ativas
      for (final gestor in gestores) {
        final lista = await repo.listarTodos(idGestor: gestor);
        expect(lista.length, 200);
      }
      // Total no sistema: 1000
      int total = 0;
      for (final gestor in gestores) {
        total += (await repo.listarTodos(idGestor: gestor)).length;
      }
      expect(total, 1000);
    });
  });
}
