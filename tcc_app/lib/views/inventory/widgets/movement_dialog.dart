import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/movement_model.dart';
import '../../../models/product_model.dart';

class MovementDialog extends StatefulWidget {
  const MovementDialog({
    super.key,
    required this.product,
    this.initialType = MovementType.ENTRADA,
  });

  final ProductModel product;
  final MovementType initialType;

  static Future<MovementModel?> show(
    BuildContext context, {
    required ProductModel product,
    MovementType initialType = MovementType.ENTRADA,
  }) => showDialog<MovementModel>(
    context: context,
    builder: (_) => MovementDialog(product: product, initialType: initialType),
  );

  @override
  State<MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<MovementDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  final _reasonController = TextEditingController();
  late MovementType _type;

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;

  int get _newStock =>
      widget.product.cantidad +
      (_type == MovementType.ENTRADA ? _quantity : -_quantity);

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEntry = _type == MovementType.ENTRADA;
    final previewColor = _newStock < 0
        ? Theme.of(context).colorScheme.error
        : _newStock <= widget.product.stockMinimo
        ? AppColors.warning
        : AppColors.success;
    return AlertDialog(
      title: const Text('Registrar movimiento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.nombre,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Stock actual: ${widget.product.cantidad} unidades',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<MovementType>(
                segments: const [
                  ButtonSegment(
                    value: MovementType.ENTRADA,
                    label: Text('Entrada'),
                    icon: Icon(Icons.add_rounded),
                  ),
                  ButtonSegment(
                    value: MovementType.SALIDA,
                    label: Text('Salida'),
                    icon: Icon(Icons.remove_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() {
                  _type = selection.first;
                }),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
                validator: _validateQuantity,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Motivo (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: previewColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: previewColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stacked_bar_chart_rounded, color: previewColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nuevo stock estimado',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$_newStock uds.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: previewColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEntry && _quantity > widget.product.cantidad) ...[
                const SizedBox(height: 8),
                Text(
                  'La salida supera el stock disponible.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: Icon(isEntry ? Icons.add_rounded : Icons.remove_rounded),
          label: Text(isEntry ? 'Registrar entrada' : 'Registrar salida'),
        ),
      ],
    );
  }

  String? _validateQuantity(String? value) {
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity == null || quantity <= 0) {
      return 'Ingresa una cantidad entera mayor que cero';
    }
    if (_type == MovementType.SALIDA && quantity > widget.product.cantidad) {
      return 'No puedes retirar más de ${widget.product.cantidad} unidades';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final productId = widget.product.id;
    if (productId == null) return;
    Navigator.of(context).pop(
      MovementModel(
        idProducto: productId,
        tipo: _type,
        cantidad: _quantity,
        motivo: _reasonController.text.trim(),
        fecha: DateTime.now(),
      ),
    );
  }
}
