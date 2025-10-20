// functions/src/index.ts
// Forçando o deploy em 18/10/2025
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getMessaging} from "firebase-admin/messaging";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

initializeApp({
  projectId: "gerenciar-acdf5",
});

interface Agendamento {
  idTecnico: string;
  idCliente: string;
  dataHora: Timestamp;
  lembreteNotificacao?: string;
  notificacaoEnviada?: boolean;
}

interface Cliente {
  nome: string;
}

// ============================================================================
// FUNÇÃO 1: Notifica instantaneamente sobre um NOVO agendamento
// ============================================================================
export const notificarNovoAgendamento = onDocumentCreated(
    {
      document: "agendamentos/{agendamentoId}",
      region: "southamerica-east1",
    },
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        logger.log("Nenhum dado no evento de criação.");
        return;
      }

      const agendamento = snapshot.data() as Agendamento;
      if (!agendamento?.idTecnico || !agendamento.idCliente) {
        logger.log("Dados do agendamento incompletos na criação.");
        return;
      }

      const {idTecnico, idCliente} = agendamento;

      const tokensSnapshot = await getFirestore()
          .collection("usuarios").doc(idTecnico).collection("tokens").get();

      if (tokensSnapshot.empty) {
        logger.log(`Técnico ${idTecnico} sem tokens para notificação.`);
        return;
      }
      const tokens = tokensSnapshot.docs.map((doc) => doc.id);

      const clienteDoc = await getFirestore()
          .collection("clientes").doc(idCliente).get();
      const nomeCliente =
      (clienteDoc.data() as Cliente | undefined)?.nome || "Cliente";

      const payload = {
        notification: {
          title: "Novo Agendamento!",
          body: `Você tem um novo atendimento para o cliente: ${nomeCliente}.`,
          sound: "default",
        },
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "agendamentoId": snapshot.id,
        },
      };

      logger.log(
          `Enviando notificação de NOVO agendamento para o técnico ${idTecnico}.`,
      );
      return getMessaging().sendToDevice(tokens, payload);
    },
);

// ============================================================================
// FUNÇÃO 2: Envia lembretes de agendamentos futuros
// ============================================================================
export const enviarLembretesDeAgendamento = onSchedule(
    {schedule: "every 15 minutes", region: "southamerica-east1"},
    async () => {
      logger.log("Iniciando verificação de lembretes de agendamento.");
      const now = Timestamp.now();
      const db = getFirestore();

      const agendamentosRef = db.collection("agendamentos");
      const query = agendamentosRef
          .where("ativo", "==", true)
          .where("notificacaoEnviada", "==", false)
          .where("dataHora", ">", now);

      const snapshot = await query.get();

      if (snapshot.empty) {
        logger.log("Nenhum lembrete a ser enviado.");
        return;
      }

      const promises: Promise<unknown>[] = [];

      snapshot.forEach(async (doc) => {
        const agendamento = doc.data() as Agendamento;
        const {dataHora, lembreteNotificacao, idTecnico, idCliente} = agendamento;

        if (!lembreteNotificacao) return;

        const dataHoraLembrete =
         calcularHorarioLembrete(dataHora, lembreteNotificacao);

        if (dataHoraLembrete.toMillis() <= now.toMillis()) {
          logger.log(`Horário de enviar lembrete para agendamento ${doc.id}`);

          const tokensSnapshot = await db.collection("usuarios")
              .doc(idTecnico).collection("tokens").get();
          if (tokensSnapshot.empty) {
            logger.log(`Técnico ${idTecnico} sem tokens para lembrete.`);
            return;
          }
          const tokens = tokensSnapshot.docs.map((tokenDoc) => tokenDoc.id);

          const clienteDoc = await db.collection("clientes").doc(idCliente).get();
          const nomeCliente =
           (clienteDoc.data() as Cliente | undefined)?.nome || "Cliente";

          const payload = {
            notification: {
              title: "Lembrete de Agendamento",
              body: `Lembrete: seu atendimento com ${nomeCliente} está se aproximando.`,
              sound: "default",
            },
            data: {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "agendamentoId": doc.id,
            },
          };

          promises.push(getMessaging().sendToDevice(tokens, payload));
          promises.push(doc.ref.update({notificacaoEnviada: true}));
        }
      });

      await Promise.all(promises);
      logger.log("Verificação de lembretes concluída.");
    },
);

/*
 * Calcula o horário de envio do lembrete com base na data do agendamento.
 * @param {Timestamp} dataHora A data/hora original do agendamento.
 * @param {string} tipoLembrete A string que define a antecedência.
 * @return {Timestamp} A nova data/hora para o envio do lembrete.
*/
function calcularHorarioLembrete(
    dataHora: Timestamp,
    tipoLembrete: string,
): Timestamp {
  let milissegundosParaSubtrair = 0;
  switch (tipoLembrete) {
    case "na_hora":
      milissegundosParaSubtrair = 0;
      break;
    case "15_minutos_antes":
      milissegundosParaSubtrair = 15 * 60 * 1000;
      break;
    case "30_minutos_antes":
      milissegundosParaSubtrair = 30 * 60 * 1000;
      break;
    case "1_hora_antes":
      milissegundosParaSubtrair = 60 * 60 * 1000;
      break;
    case "1_dia_antes":
      milissegundosParaSubtrair = 24 * 60 * 60 * 1000;
      break;
  }
  return Timestamp.fromMillis(dataHora.toMillis() - milissegundosParaSubtrair);
}
