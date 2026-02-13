import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import axios from "axios";

initializeApp();

const ONESIGNAL_APP_ID = "a0e5e812-11d0-46f9-8019-4992adacdb83";
const ONESIGNAL_REST_KEY = "os_v2_app_uds6qeqr2bdptaazjgjk3lg3qpy35wbmnawuehmeramwt5ml2aqfdane5utub3ksbytshvd6fp4kp42rkqczns2xkxzecrvfcn6reeq";

interface Agendamento {
  idTecnico: string;
  idCliente: string;
  dataHora: Timestamp;
  lembreteNotificacao?: string;
  notificacaoEnviada?: boolean;
}

// Função auxiliar para enviar via OneSignal
async function enviarNotificacaoOneSignal(idUsuario: string, titulo: string, mensagem: string, data: any) {
  try {
    await axios.post("https://onesignal.com/api/v1/notifications", {
      app_id: ONESIGNAL_APP_ID,
      headings: {en: titulo, pt: titulo},
      contents: {en: mensagem, pt: mensagem},
      include_external_user_ids: [idUsuario], // Usa o ID do técnico como alvo
      data: data}, {
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${ONESIGNAL_REST_KEY}`}});
    logger.log(`Notificação enviada para o usuário: ${idUsuario}`);
  } catch (error) {
    logger.error("Erro ao enviar para OneSignal:", error);
  }
}

export const notificarNovoAgendamento = onDocumentCreated(
    {document: "agendamentos/{agendamentoId}", region: "southamerica-east1"},
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) return;

      const agendamento = snapshot.data() as Agendamento;
      const clienteDoc = await getFirestore().collection("clientes").doc(agendamento.idCliente).get();
      const nomeCliente = clienteDoc.data()?.nome || "Cliente";

      await enviarNotificacaoOneSignal(agendamento.idTecnico,
          "Novo Agendamento!",
          `Você tem um novo atendimento para o cliente: ${nomeCliente}.`,
          {agendamentoId: snapshot.id}
      );
    }
);

export const enviarLembretesDeAgendamento = onSchedule(
    {schedule: "every 15 minutes", region: "southamerica-east1"},
    async () => {
      const now = Timestamp.now();
      const db = getFirestore();

      // Busca agendamentos ativos que ainda não tiveram notificação enviada
      const snapshot = await db.collection("agendamentos")
          .where("ativo", "==", true)
          .where("notificacaoEnviada", "==", false)
          .where("dataHora", ">", now).get();

      for (const doc of snapshot.docs) {
        const agendamento = doc.data() as Agendamento;
        // Pula se não houver configuração de lembrete
        if (!agendamento.lembreteNotificacao) continue;

        // Calcula quando a notificação deveria ser enviada
        const dataHoraLembrete = calcularHorarioLembrete(
            agendamento.dataHora,
            agendamento.lembreteNotificacao
        );

        // Se o horário do lembrete já passou ou é agora, envia a notificação
        if (dataHoraLembrete.toMillis() <= now.toMillis()) {
          await enviarNotificacaoOneSignal(
              agendamento.idTecnico,
              "Lembrete de Agendamento",
              "Seu atendimento está se aproximando.",
              {agendamentoId: doc.id}
          );
          // Marca como enviada para não repetir no próximo ciclo de 15 min
          await doc.ref.update({notificacaoEnviada: true});
          logger.log(`Lembrete enviado com sucesso para o agendamento: ${doc.id}`);
        }
      }
    }
);

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
    default:
      milissegundosParaSubtrair = 0;
  }

  return Timestamp.fromMillis(dataHora.toMillis() - milissegundosParaSubtrair);
}
