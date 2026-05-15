// lib/apresentacao/widgets/_widget_selecao.dart
import 'package:flutter/material.dart';

class WidgetSelecao extends StatelessWidget {
  final String label;
  final String valor;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  const WidgetSelecao({
    super.key,
    required this.label,
    required this.valor,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return TextFormField(
      controller: TextEditingController(text: valor),
      readOnly: true,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.search,
            color: enabled ? null : Theme.of(context).disabledColor),
      ),
      validator: validator,
    );
  }
}
