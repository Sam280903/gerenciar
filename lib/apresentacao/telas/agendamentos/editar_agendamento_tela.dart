import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:intl/intl.dart';

class EditarAgendamentoTela extends StatefulWidget {
  final Agendamento agendamento;
  final AtualizarAgendamento? atualizarAgendamento;
  const EditarAgendamentoTela({super.key, required this.agendamento, this.atualizarAgendamento});

  @override
  State<EditarAgendamentoTela> createState() => _EditarAgendamentoTelaState();
}

class _EditarAgendamentoTelaState extends State<EditarAgendamentoTela> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  late TextEditingController _obsController;

  late DateTime _dataSelecionada;
  late TimeOfDay _horaSelecionada;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.agendamento.dataHora;
    _horaSelecionada = TimeOfDay.fromDateTime(widget.agendamento.dataHora);

    _dataController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_dataSelecionada));
    _horaController =
        TextEditingController(); // Será inicializado no didChangeDependencies
    _obsController = TextEditingController(text: widget.agendamento.observacao);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa aqui para ter acesso ao context
    _horaController.text = _horaSelecionada.format(context);
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _dataController.text = DateFormat('dd/MM/yyyy').format(data);
      });
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
        _horaController.text = hora.format(context);
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      try {
        final dataHoraAgendamento = DateTime(
          _dataSelecionada.year,
          _dataSelecionada.month,
          _dataSelecionada.day,
          _horaSelecionada.hour,
          _horaSelecionada.minute,
        );

        final agendamentoAtualizado = Agendamento(
          id: widget.agendamento.id,
          idCliente: widget.agendamento.idCliente,
          idTecnico: widget.agendamento.idTecnico,
          idGestor: widget.agendamento.idGestor, // ADICIONADO (ESSENCIAL)
          dataHora: dataHoraAgendamento,
          observacao: _obsController.text.trim(),
          status: widget.agendamento.status,
          ativo: widget.agendamento.ativo,
        );

        await (widget.atualizarAgendamento ?? AtualizarAgendamento(AgendamentoRepositorioAdaptativo()))
            .executar(agendamentoAtualizado);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Agendamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.redAccent,
          ));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(labelText: 'Data'),
                      readOnly: true,
                      onTap: _selecionarData,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horaController,
                      decoration: const InputDecoration(labelText: 'Horário'),
                      readOnly: true,
                      onTap: _selecionarHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _salvarAlteracoes,
                      child: const Text('SALVAR ALTERAÇÕES'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
