# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GerenciAR** is a mobile service management application built with Flutter/Dart for air conditioning and refrigeration technicians. It's a final course project (TFC) with **offline-first architecture**: all data is stored locally in SQLite and automatically synchronized with Firebase when online.

**Key Characteristics:**
- Clean Architecture (Presentation → Domain → Data layers)
- Adaptive Repository Pattern for intelligent online/offline switching
- Portuguese localization with Brazilian field formatting
- No state management library (direct repository usage + setState)
- Firebase Auth + OneSignal push notifications
- 118 source files, 98 test files, 346+ passing tests

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/servicos/relatorio_servico_test.dart

# Generate mocks (required for testing)
flutter pub run build_runner build

# Code analysis
flutter analyze

# Get test coverage
flutter test --coverage
```

## Architecture: Three-Layer Pattern

### 1. **Presentation Layer** (`lib/apresentacao/`)
- Flutter screens using StatefulWidget
- Screen-specific state via `setState`
- No Provider/Bloc - repositories used directly
- Screens are feature-organized: `agendamentos/`, `clientes/`, `ordens_servico/`, etc.

### 2. **Domain Layer** (`lib/dominio/`)
- **Entities**: 8 core business objects (Cliente, Tecnico, Agendamento, OrdemServico, etc.)
- **Use Cases**: 31+ business operations (CreateCliente, ListarAgendamentos, etc.)
- **Repository Interfaces**: Abstract data access contracts
- Framework-independent business logic

### 3. **Data Layer** (`lib/dados/`)
- **Adaptive Repositories** (`*_repositorio_adaptativo.dart`): Smart adapter that automatically selects:
  - `*_repositorio_impl.dart` - Firebase (online)
  - `*_repositorio_impl_sqlite.dart` - SQLite (offline)
- **Data Sources**: Direct Firestore or SQLite operations
- **Models**: Data transfer objects with `toMap()` / `fromMap()` serialization

**Key Pattern**: Repositories check connectivity via `connectivity_plus` and automatically use the appropriate implementation. Synchronization service handles bidirectional sync.

**Adaptive Repository Dual-Write Rule**: When online, ALL mutation methods (`adicionar`, `atualizar`, `inativar`, `reativar`) must:
1. Write to Firebase (online repo)
2. Mirror the change to SQLite (offline repo / direct SQLite source)
3. Call `marcarComoSincronizado(id)` on the SQLite source

Only `adicionar` in some repos implements this fully — always verify all mutations follow this pattern when editing adaptive repositories.

**Sync Service uses `listarRecentes()`**: Firebase data sources expose a `listarRecentes()` method (limit 500, no `idGestor` filter) used exclusively by `SincronizacaoServico` to download all records for local mirroring. This is separate from `listarTodos()` (which filters by `idGestor`) used by use cases.

## Critical Services

### `lib/servicos/sincronizacao_servico.dart`
- **Singleton** managing data sync between SQLite and Firebase
- Periodic sync every 5 minutes (configurable via Timer)
- Event-driven sync with 3-second debounce when connectivity restored
- Guard flag `_sincronizando` prevents concurrent sync calls (race condition protection)
- **Method**: `sincronizarDados()` - uploads pending local changes, downloads cloud updates
- Filters: Pending items (not yet synced) are protected from cloud overwrites

### `lib/servicos/autenticacao_servico.dart`
- Firebase Authentication wrapper
- OneSignal integration for push notifications
- User data caching with **30-minute TTL** (timestamp-based expiration)
- Cache cleared on logout to prevent data leakage between users
- Error messages translated to Portuguese

### `lib/servicos/relatorio_servico.dart`
- Report generation with filters (date range, technician, client, status)
- **Optimized**: Uses batch loading (all clients + technicians once) with Map lookups instead of N+1 queries
- Returns `OrdemServicoDetalhada` (work order + linked client + technician)

## Key Business Logic

### Appointment Conflict Detection
- **File**: `dominio/casos_uso/agendamento/rf02_conflito_agendamento.dart`
- Prevents double-booking: same technician cannot have two appointments at same time
- Checked in `cadastro_agendamento_tela.dart` before saving

### Form Validators (Recently Enhanced)
- **Email**: Requires @ and .
- **Telefone**: Minimum 10 digits after masking
- **CEP**: Exactly 8 digits if provided
- **UF**: Exactly 2 letters
- **Agendamento**: Shows SnackBar error if gestor identification fails

### Offline-First Data Flow
1. User creates/edits data → stored in SQLite with `sincronizado: false`
2. When online: sync service uploads pending changes
3. Download updates from Firebase (excluding items pending upload)
4. On sync failure: data stays in SQLite, retry on next sync cycle

## Firebase Configuration

- **Project**: `gerenciar-acdf5`
- **Collections**: `usuarios`, `clientes`, `tecnicos`, `agendamentos`, `ordens_servico`, `formas_pagamento`, `gestores`, `configuracao`
- **Auth**: Email/password authentication with role-based access (gestor/tecnico)
- **OneSignal Integration**: App ID configured via String.fromEnvironment (not hardcoded)

## Database Schema (SQLite)

Each entity has a SQLite table initialized in `lib/dados/fontes_dados/sqlite/sqlite_conexao.dart`:
- `clientes` - Customer data
- `tecnicos` - Technician data
- `agendamentos` - Appointments
- `ordens_servico` - Work orders
- `formas_pagamento` - Payment methods
- Boolean `sincronizado` field on all tables (true = synced with cloud)

## Testing Strategy

- **312 total tests** - organized by layer (apresentacao/, dominio/, fluxo/)
- **Mockito** for mocking repositories
- **Test file location**: Mirror lib/ structure (e.g., test file for `lib/dominio/casos_uso/agendamento/criar_agendamento.dart` is `test/dominio/casos_uso/agendamento/criar_agendamento_test.dart`)
- **Key tests**: Conflict detection, report generation, authentication, synchronization
- **Run single test**: `flutter test test/servicos/relatorio_servico_test.dart`

## Code Style & Conventions

- **Language**: Portuguese (classes, variables, comments)
- **Naming**: 
  - Classes: PascalCase (`ClienteRepositorio`, `CadastroClienteTela`)
  - Variables/methods: camelCase (`_idGestor`, `sincronizarDados`)
  - Private: Leading underscore (`_cacheUsuario`, `_timer`)
- **Comments**: Use `debugPrint()` (not `print()`) for debug output
- **Error Handling**: Wrap user-facing errors in try/catch, provide Portuguese messages
- **No console errors**: Use `debugPrint()` only within `if (kDebugMode)` guards

## Known Patterns & Gotchas

1. **Async void avoided**: Methods returning Future<void> allow proper error propagation
2. **Repository selection**: Adaptive repos check `connectivity_plus` for online/offline decision - ensure device has connectivity permission
3. **Sync timing**: App initializes sync on startup + periodic timer + connectivity changes (debounced)
4. **Cache TTL**: User data cache expires after 30 minutes - force refresh with `buscarDadosUsuarioLogado(forcarAtualizacao: true)`
5. **Pending items protected**: During sync, items marked `sincronizado: false` won't be overwritten by cloud data
6. **Firebase queries**: Complex filters moved to code level (Map lookups) to avoid composite index requirements
7. **Address format**: Stored as a single string: `"Logradouro, Nº X, Complemento, Bairro, Cidade, UF"`. Number is prefixed with `"Nº "` (unique sentinel). When parsing back to fields, use trailing indices (`parts.last` = UF, `parts.length-2` = cidade, `parts.length-3` = bairro) — never fixed indices, as número and complemento are optional.
8. **Nullable string fields**: Fields like `cpf` (`String?`) must stay `null` when not provided — never coerce to `''`. In `fromMap()`, use `map['field']?.toString()` (no `?? ''`). In UI, convert empty controllers to null before saving: `text.isEmpty ? null : text`.
9. **`mounted` guard placement**: Add `if (!mounted) return;` immediately before the *first* `setState` call in any async method — not just around SnackBar/navigation calls.

## When Adding Features

1. **New use case**: Create in `dominio/casos_uso/{feature}/` and add tests
2. **New entity**: Add to `dominio/entidades/`, create model, and implementations in both Firebase and SQLite sources
3. **UI screen**: Create in `apresentacao/telas/{feature}/`, use repositories directly, manage state with setState
4. **Data access**: Implement both `_repositorio_impl.dart` (Firestore) and `_repositorio_impl_sqlite.dart` (SQLite), ensure sync covers it
5. **Sync aware**: Mark new data fields with `sincronizado` field for pending change tracking

## Important Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | Firebase init, OneSignal setup, sync service start |
| `lib/aplicativo.dart` | App routes, theme, auth gate |
| `lib/app/rotas.dart` | Named route definitions |
| `lib/servicos/sincronizacao_servico.dart` | Core sync logic (study for offline-first understanding) |
| `lib/servicos/autenticacao_servico.dart` | Auth + cache management |
| `lib/dados/repositorios/*/` | Adaptive pattern examples |
| `test/servicos/relatorio_servico_test.dart` | Example of mocking repositories |
| `.firebaserc` | Firebase project config |
