# Checklist de Mudanças — Status de Cancelamento e Reordenação de Abas

## 1. Máscara de Telefone em Técnicos
- [x] `cadastro_tecnico_tela.dart` — adicionado `TelefoneInputFormatter` + `FilteringTextInputFormatter`
- [x] `editar_tecnico_tela.dart` — adicionado `TelefoneInputFormatter` + `FilteringTextInputFormatter`

## 2. Status Cancelada em Ordens de Serviço (OS)

### Entidade e Persistência
- [x] `ordem_servico.dart` — campo `justificativaCancelamento` + comentário status atualizado
- [x] `ordem_servico_model.dart` — serialização do novo campo (fromMap, toMap, toMapForDb, fromDbMap, toEntidade)
- [x] `sqlite_conexao.dart` — versão bumped para 6, migração ALTER TABLE, coluna em CREATE TABLE
- [x] `ordem_servico_sqlite.dart` — método `cancelar()`
- [x] `ordem_servico_firebase.dart` — método `cancelar()`

### Repositórios
- [x] `ordem_servico_repositorio_interface.dart` — assinatura `cancelar()`
- [x] `ordem_servico_repositorio_impl.dart` — implementação Firebase
- [x] `ordem_servico_repositorio_impl_sqlite.dart` — implementação SQLite
- [x] `ordem_servico_repositorio_adaptativo.dart` — delegação online/offline
- [x] `ordem_servico_repositorio_memoria.dart` (test) — implementação em memória

### Caso de Uso
- [x] Novo arquivo: `cancelar_ordem_servico.dart`

### UI — Lista
- [x] `ordens_servico_tela.dart`:
  - [x] TabController length: 4 → 5
  - [x] Nova lista: `_todosCanceladas` + `_canceladasFiltrados`
  - [x] Switch case: adicionar caso `'Cancelada'`
  - [x] Abas reordenadas: `PENDENTES → EM ANDAMENTO → REABERTAS → CONCLUÍDAS → CANCELADAS`
  - [x] Color: `'Cancelada'` → `Colors.grey`

### UI — Detalhes
- [x] `detalhes_os_tela.dart`:
  - [x] Import: `CancelarOrdemServico`
  - [x] Método: `_cancelarOS()` (diálogo com justificativa)
  - [x] Exibição: mostra `justificativaCancelamento` quando status é Cancelada
  - [x] Botão: "CANCELAR OS" (gestor, quando não concluída/cancelada)
  - [x] Color: `'cancelada'` → `Colors.grey`
  - [x] Lógica: oculta EDITAR para canceladas

### Relatórios
- [x] `relatorios_tela.dart` — filtro dropdown: adicionar 'Cancelada'
- [x] `relatorio_resultado_tela.dart`:
  - [x] Color: `'cancelada'` → `Colors.grey`
  - [x] Valor Total: excluir OS com status Cancelada

## 3. Status Cancelado em Agendamentos + Reordenação

### UI — Lista
- [x] `agendamentos_tela.dart`:
  - [x] Listas renomeadas: `_todosProximos` → `_todosPendentes` + nova `_todosConfirmados`
  - [x] TabController length: 5 → 6
  - [x] Abas reordenadas: `PENDENTES → CONFIRMADOS → CONCLUÍDOS → ANTIGOS → CANCELADOS → INATIVOS`
  - [x] Classificação: split status Pendente vs Confirmado (quando data >= hoje)
  - [x] `_otimizarRota()`: usa apenas `_todosConfirmados` + mensagem atualizada
  - [x] `_filtrarAgendamentos()`: helper inline para reduzir duplicação

### Testes
- [x] `agendamentos_tela_test.dart` — mensagem esperada atualizada

## 4. Análise e Testes
- [x] `flutter analyze` — passando (1 warning pré-existente)
- [x] `flutter test` — 312 testes passando

---

## Validação em Desenvolvimento

### Para Testar:

**OS — Cancelamento:**
- [x] Criar uma OS, verificar que tem status Pendente
- [x] Abrir detalhes, clicar "CANCELAR OS"
- [x] Escrever justificativa, confirmar
- [x] Verificar que aparece na aba CANCELADAS
- [x] Verificar que justificativa aparece em detalhes
- [x] Verificar que Valor Total do relatório exclui OS cancelada

**OS — Reordenação:**
- [x] Verificar ordem das abas: PENDENTES, EM ANDAMENTO, REABERTAS, CONCLUÍDAS, CANCELADAS

**Agendamentos — Separação:**
- [x] Criar agendamento (status Pendente por padrão) → aparece em PENDENTES
- [x] Confirmar agendamento → muda para CONFIRMADOS
- [x] Verificar que agendamentos passados/pendentes vão para ANTIGOS

**Agendamentos — Otimizar Rota:**
- [x] Agendar 2+ confirmados para hoje
- [x] Clicar "OTIMIZAR ROTA DO DIA"
- [x] Verificar que abre Google Maps
- [x] Tentar com só pendentes → mostra erro "confirmados"

**Técnicos — Mascara:**
- [x] Cadastrar técnico, digitar telefone → mascara formata `(99) 99999-9999`
- [x] Editar técnico → mascara mantém

---

**Status:** ✅ Pronto para testes
