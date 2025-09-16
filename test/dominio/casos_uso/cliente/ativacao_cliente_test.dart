// test/dominio/casos_uso/cliente/ativacao_cliente_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/inativar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/reativar_cliente.dart';

// Usa o mock já gerado anteriormente
import 'cadastrar_cliente_test.mocks.dart';

void main() {
  late MockClienteRepositorioInterface mockRepositorio;
  late InativarCliente inativarCasoDeUso;
  late ReativarCliente reativarCasoDeUso;

  setUp(() {
    mockRepositorio = MockClienteRepositorioInterface();
    inativarCasoDeUso = InativarCliente(mockRepositorio);
    reativarCasoDeUso = ReativarCliente(mockRepositorio);
  });

  const clienteId = 'cliente-abc';

  group('Ativação de Clientes', () {
    test('Deve chamar o método inativar do repositório', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) async => {});
      await inativarCasoDeUso.executar(clienteId);
      verify(mockRepositorio.inativar(clienteId));
      verifyNoMoreInteractions(mockRepositorio);
    });

    test('Deve chamar o método reativar do repositório', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) async => {});
      await reativarCasoDeUso.executar(clienteId);
      verify(mockRepositorio.reativar(clienteId));
      verifyNoMoreInteractions(mockRepositorio);
    });
  });
}
