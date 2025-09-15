// Ficheiro: functions/src/index.ts

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { getFirestore } from "firebase-admin/firestore";

// Inicializa o app do Firebase para ter acesso aos serviços
initializeApp();

// --- DEFINIÇÃO DOS TIPOS DE DADOS ---
interface Agendamento {
  idTecnico: string;
  idCliente: string;
}

interface Cliente {
  nome: string;
}

// Esta é a nossa função, agora escrita no novo formato v2
export const notificarNovoAgendamento = onDocumentCreated(
  // O primeiro argumento é um objeto de opções
  {
    document: "agendamentos/{agendamentoId}",
    region: "southamerica-east1", // São Paulo
  },
  // O segundo argumento é a função que será executada (o "gatilho")
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("Nenhum dado no evento. A função será encerrada.");
      return;
    }

    const agendamento = snapshot.data() as Agendamento;

    if (!agendamento || !agendamento.idTecnico || !agendamento.idCliente) {
      console.log("Dados do agendamento incompletos. A função encerrada.");
      return;
    }

    const { idTecnico, idCliente } = agendamento;

    // --- 1. Buscar os tokens de notificação do técnico ---
    const tokensSnapshot = await getFirestore()
      .collection("usuarios")
      .doc(idTecnico)
      .collection("tokens")
      .get();

    if (tokensSnapshot.empty) {
      console.log(`O técnico ${idTecnico} não possui tokens de notificação.`);
      return;
    }
    const tokens = tokensSnapshot.docs.map((doc) => doc.id);

    // --- 2. Buscar o nome do cliente para a mensagem ---
    const clienteDoc = await getFirestore()
      .collection("clientes")
      .doc(idCliente)
      .get();

    const dadosCliente = clienteDoc.data() as Cliente | undefined;
    const nomeCliente = dadosCliente?.nome || "Cliente não identificado";

    // --- 3. Montar a mensagem da notificação ---
    // A linha do "body" foi quebrada para respeitar o limite de 80 caracteres.
    const notificationBody =
      `Você tem um novo atendimento para o cliente: ${nomeCliente}. ` +
      "Verifique a sua agenda.";

    const payload = {
      notification: {
        title: "Novo Agendamento!",
        body: notificationBody,
        sound: "default",
      },
      data: {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "agendamentoId": snapshot.id,
      },
    };

    // --- 4. Enviar a notificação para todos os dispositivos do técnico ---
    const logMessage =
      `Enviando notificação sobre o cliente ${nomeCliente} para os tokens.`;
    console.log(logMessage, tokens);
    return getMessaging().sendToDevice(tokens, payload);
  },
);
