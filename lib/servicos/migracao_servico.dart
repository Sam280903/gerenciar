// lib/servicos/migracao_servico.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Serviço responsável por executar migrações pontuais de dados no Firestore.
/// Cada migração roda apenas uma vez, controlada pela coleção '_migracoes'.
class MigracaoServico {
  final _firestore = FirebaseFirestore.instance;

  /// Executa todas as migrações pendentes.
  Future<void> executarMigracoesPendentes() async {
    await _corrigirStatusReaberto();
  }

  /// Migração: corrige registros de OS com status 'Reaberto' → 'Reaberta'.
  /// O status foi salvo com gênero incorreto em versões anteriores.
  Future<void> _corrigirStatusReaberto() async {
    const chave = 'corrigir_status_reaberto_v1';

    // Verifica se esta migração já foi executada
    final doc = await _firestore.collection('_migracoes').doc(chave).get();
    if (doc.exists) return;

    try {
      final snapshot = await _firestore
          .collection('ordens_servico')
          .where('status', isEqualTo: 'Reaberto')
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) debugPrint('[Migração] Nenhuma OS com status "Reaberto" encontrada.');
      } else {
        // Usa batch para atualizar todos de uma vez (mais eficiente)
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'status': 'Reaberta'});
        }
        await batch.commit();

        if (kDebugMode) {
          debugPrint('[Migração] ${snapshot.docs.length} OS corrigida(s): '
              '"Reaberto" → "Reaberta".');
        }
      }

      // Marca a migração como executada
      await _firestore.collection('_migracoes').doc(chave).set({
        'executadaEm': FieldValue.serverTimestamp(),
        'registrosAfetados': snapshot.docs.length,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[Migração] Erro ao corrigir status: $e');
      // Não marca como executada, será retentada na próxima abertura
    }
  }
}
