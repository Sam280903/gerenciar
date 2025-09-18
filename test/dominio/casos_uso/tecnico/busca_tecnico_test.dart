// test/dominio/casos_uso/tecnico/busca_tecnico_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';

import 'cadastrar_tecnico_test.mocks.dart';

void main() {
  late MockTecnicoRepositorioInterface mockRepositorio;
  late BuscarTecnicoPorId buscarPorId;
  late ListarTecnicos listar;

  setUp(() {
    mockRepositorio = MockTecnicoRepositorioInterface();
    buscarPorId = BuscarTecnicoPorId(mockRepositorio);
    listar = ListarTecnicos(mockRepositorio);
  });

  final tecnicoExemplo = Tecnico(
    id: 'tec-1',
    nome: 'Flávio Amorim',
    email: 'flavio@teste.com',
    telefone: '64999999999',
    ativo: true,
  );
//
  group('Busca de Técnicos', () {
    test('Deve retornar um técnico ao buscar por id', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) async => tecnicoExemplo);
      final resultado = await buscarPorId.executar('tec-1');
      expect(resultado, tecnicoExemplo);
      verify(mockRepositorio.buscarPorId('tec-1'));
    });

    test('Deve retornar uma lista de técnicos', () async {
      final lista = [tecnicoExemplo];
      when(mockRepositorio.listarTodos(
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) async => lista);
      final resultado = await listar.executar();
      expect(resultado, lista);
      verify(mockRepositorio.listarTodos(incluirInativos: false));
    });
  });
}
