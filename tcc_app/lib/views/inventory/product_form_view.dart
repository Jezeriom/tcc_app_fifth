import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';

class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, this.product});

  final ProductModel? product;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _skuController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _minimumStockController;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.nombre ?? '');
    _descriptionController = TextEditingController(
      text: product?.descripcion ?? '',
    );
    _categoryController = TextEditingController(text: product?.categoria ?? '');
    _skuController = TextEditingController(text: product?.codigoSku ?? '');
    _quantityController = TextEditingController(
      text: product?.cantidad.toString() ?? '0',
    );
    _priceController = TextEditingController(
      text: product?.precio.toString() ?? '',
    );
    _minimumStockController = TextEditingController(
      text: product?.stockMinimo.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              _isEditing
                  ? 'Actualiza la información del producto.'
                  : 'Completa los datos para agregarlo al inventario.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            _SectionLabel(title: 'Información general'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) => _required(value, 'El nombre'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _categoryController.text),
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) return inventory.categorias;
                return inventory.categorias.where(
                  (category) => category.toLowerCase().contains(query),
                );
              },
              onSelected: (value) => _categoryController.text = value,
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                if (controller.text != _categoryController.text) {
                  controller.value = _categoryController.value;
                }
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) => _categoryController.text = value,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    hintText: 'Elige una existente o escribe una nueva',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) => _required(value, 'La categoría'),
                  onFieldSubmitted: (_) => onSubmitted(),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skuController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código SKU *',
                prefixIcon: Icon(Icons.qr_code_2_rounded),
              ),
              validator: (value) => _required(value, 'El SKU'),
            ),
            const SizedBox(height: 24),
            _SectionLabel(title: 'Existencias y precio'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad *',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    validator: (value) => _integer(value, 'La cantidad'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minimumStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock mínimo *',
                      prefixIcon: Icon(Icons.warning_amber_rounded),
                    ),
                    validator: (value) => _integer(value, 'El stock mínimo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio unitario *',
                prefixText: r'$ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: _validatePrice,
            ),
            if (inventory.errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                inventory.errorMessage!,
                style: TextStyle(color: colors.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_saving ? 'Guardando…' : 'Guardar producto'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label es obligatorio' : null;

  String? _integer(String? value, String label) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return '$label debe ser un número entero';
    if (parsed < 0) return '$label no puede ser negativo';
    return null;
  }

  String? _validatePrice(String? value) {
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null) return 'Ingresa un precio válido';
    if (!parsed.isFinite || parsed < 0) {
      return 'El precio no puede ser negativo';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final original = widget.product;
    final product = ProductModel(
      id: original?.id,
      nombre: _nameController.text.trim(),
      descripcion: _descriptionController.text.trim(),
      categoria: _categoryController.text.trim(),
      cantidad: int.parse(_quantityController.text.trim()),
      precio: double.parse(_priceController.text.trim().replaceAll(',', '.')),
      fechaIngreso: original?.fechaIngreso ?? DateTime.now(),
      stockMinimo: int.parse(_minimumStockController.text.trim()),
      codigoSku: _skuController.text.trim(),
    );

    final inventory = context.read<InventoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final success = _isEditing
        ? await inventory.updateProduct(product) ?? false
        : await inventory.registerProduct(product) != null;
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF246B4A),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(_isEditing ? 'Producto actualizado.' : 'Producto creado.'),
            ],
          ),
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w800),
  );
}
