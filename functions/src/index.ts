import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import axios from "axios";

initializeApp();

const ONESIGNAL_APP_ID = "a0e5e812-11d0-46f9-8019-4992adacdb83";
const onesignalRestKey = defineSecret("ONESIGNAL_REST_KEY");

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
      headings: { en: titulo, pt: titulo },
      contents: { en: mensagem, pt: mensagem },
      include_external_user_ids: [idUsuario],
      data: data
    }, {
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${onesignalRestKey.value()}`
      }
    });
    logger.log(`Notificação enviada para o usuário: ${idUsuario}`);
  } catch (error) {
    logger.error("Erro ao enviar para OneSignal:", error);
  }
}

export const notificarNovoAgendamento = onDocumentCreated(
  { document: "agendamentos/{agendamentoId}", region: "southamerica-east1", secrets: [onesignalRestKey] },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const agendamento = snapshot.data() as Agendamento;
    const clienteDoc = await getFirestore().collection("clientes").doc(agendamento.idCliente).get();
    const dadosCliente = clienteDoc.data();
    const nomeCliente = dadosCliente?.nome || "Cliente";
    const enderecoCliente = dadosCliente?.endereco || "";

    const dataAg = agendamento.dataHora.toDate();
    const dataFormatada = formatarData(dataAg);
    const horaFormatada = formatarHora(dataAg);

    let mensagem = `Cliente: ${nomeCliente}\nData: ${dataFormatada} às ${horaFormatada}`;
    if (enderecoCliente) {
      mensagem += `\nEndereço: ${enderecoCliente}`;
    }

    await enviarNotificacaoOneSignal(agendamento.idTecnico,
      "Novo agendamento atribuído",
      mensagem,
      { agendamentoId: snapshot.id }
    );
  }
);

export const enviarLembretesDeAgendamento = onSchedule(
  { schedule: "every 1 minutes", region: "southamerica-east1", secrets: [onesignalRestKey] },
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
      if (!agendamento.lembreteNotificacao) continue;

      const dataHoraLembrete = calcularHorarioLembrete(
        agendamento.dataHora,
        agendamento.lembreteNotificacao
      );

      if (dataHoraLembrete.toMillis() <= now.toMillis()) {
        const clienteDoc = await db.collection("clientes").doc(agendamento.idCliente).get();
        const dadosCliente = clienteDoc.data();
        const nomeCliente = dadosCliente?.nome || "Cliente";
        const enderecoCliente = dadosCliente?.endereco || "";

        const dataAg = agendamento.dataHora.toDate();
        const dataFormatada = formatarData(dataAg);
        const horaFormatada = formatarHora(dataAg);
        const tituloLembrete = tituloPorTipoLembrete(agendamento.lembreteNotificacao);

        let mensagem = `Cliente: ${nomeCliente}\nData: ${dataFormatada} às ${horaFormatada}`;
        if (enderecoCliente) {
          mensagem += `\nEndereço: ${enderecoCliente}`;
        }

        await enviarNotificacaoOneSignal(
          agendamento.idTecnico,
          tituloLembrete,
          mensagem,
          { agendamentoId: doc.id }
        );
        await doc.ref.update({ notificacaoEnviada: true });
        logger.log(`Lembrete enviado com sucesso para o agendamento: ${doc.id}`);
      }
    }
  }
);

function formatarData(data: Date): string {
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit", month: "2-digit", year: "numeric",
    timeZone: "America/Sao_Paulo",
  }).format(data);
}

function formatarHora(data: Date): string {
  return new Intl.DateTimeFormat("pt-BR", {
    hour: "2-digit", minute: "2-digit",
    timeZone: "America/Sao_Paulo",
  }).format(data);
}

function tituloPorTipoLembrete(tipo: string | undefined): string {
  switch (tipo) {
    case "na_hora":
      return "Atendimento começando agora";
    case "15_minutos_antes":
      return "Atendimento em 15 minutos";
    case "30_minutos_antes":
      return "Atendimento em 30 minutos";
    case "1_hora_antes":
      return "Atendimento em 1 hora";
    case "1_dia_antes":
      return "Atendimento amanhã";
    default:
      return "Lembrete de atendimento";
  }
}

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
