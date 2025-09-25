const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {v4: uuidv4} = require("uuid");

admin.initializeApp();

// Esta função simula o caso de uso 'CadastrarOrdemServico'
// Ela pode ser chamada por um simples POST request.
exports.stressTestCreateOS = functions.https.onRequest(async (req, res) => {
  // Apenas aceita requisições POST
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  try {
    // Dados de exemplo para a Ordem de Serviço
    // Em um teste real, você pode randomizar esses dados
    const osData = {
      id: uuidv4(),
      idCliente: req.body.idCliente || "client-test-id",
      idTecnico: req.body.idTecnico || "tech-test-id",
      idFormaPagamento: "fp-test-id",
      dataHoraInicio: admin.firestore.Timestamp.now(),
      descricao: "Teste de estresse: verificação de performance.",
      valor: Math.random() * 500, // Valor aleatório
      prioridade: "Baixa",
      status: "Pendente",
      ativo: true,
    };

    // Salva o documento na coleção 'ordens_servico'
    await admin.firestore()
        .collection("ordens_servico")
        .doc(osData.id)
        .set(osData);

    res.status(201).send({success: true, id: osData.id});
  } catch (error) {
    console.error("Erro no teste de estresse:", error);
    res.status(500).send({success: false, error: "Internal Server Error"});
  }
});
