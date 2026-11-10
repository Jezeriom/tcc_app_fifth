import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/movement_model.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';
import '../history/movement_history_view.dart';
import 'product_form_view.dart';
import 'widgets/movement_dialog.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late ProductModel _product;
  late Future<List<MovementModel>> _movementHistory;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _movementHistory = context.read<InventoryProvider>().getProductMovements(
      _product.id!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('d MMM yyyy', 'es_CO');
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: [
          IconButton(
            tooltip: 'Editar producto',
            onPressed: _editProduct,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar producto',
            onPressed: _deleteProduct,
            icon: Icon(Icons.delete_outline_rounded, color: colors.error),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primaryContainer, colors.surfaceContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'product-image-${_product.id}',
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        size: 30,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product.nombre,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_product.categoria} · SKU ${_product.codigoSku}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      width: width,
                      label: 'Existencias',
                      value: '${_product.cantidad} uds.',
                      icon: Icons.widgets_outlined,
                      color: _product.cantidad <= _product.stockMinimo
                          ? AppColors.danger
                          : AppColors.primary,
                    ),
                    _MetricCard(
                      width: width,
                      label: 'Stock mínimo',
                      value: '${_product.stockMinimo} uds.',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                    ),
                    _MetricCard(
                      width: width,
                      label: 'Precio unitario',
                      value: currency.format(_product.precio),
                      icon: Icons.sell_outlined,
                      color: const Color(0xFF7556A5),
                    ),
                    _MetricCard(
                      width: width,
                      label: 'Valor en inventario',
                      value: currency.format(
                        _product.precio * _product.cantidad,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF426B9A),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Información',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Descripción',
                    value: _product.descripcion.isEmpty
                        ? 'Sin descripción'
                        : _product.descripcion,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _InfoRow(
                    label: 'Fecha de ingreso',
                    value: dateFormat.format(_product.fechaIngreso),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Movimientos recientes',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: _reloadHistory,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Actualizar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<MovementModel>>(
              future: _movementHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(22),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'No se pudo cargar el historial: ${snapshot.error}',
                  );
                }
                final movements = snapshot.data ?? const <MovementModel>[];
                if (movements.isEmpty) {
                  return const _NoMovementsCard();
                }
                return Column(
                  children: movements
                      .take(10)
                      .map(
                        (movement) => MovementListTile(
                          movement: movement,
                          showProduct: false,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openMovement(MovementType.ENTRADA),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Entrada'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _openMovement(MovementType.SALIDA),
                icon: const Icon(Icons.remove_rounded),
                label: const Text('Salida'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    final id = _product.id;
    if (id == null) return;
    final provider = context.read<InventoryProvider>();
    final updated = await provider.getProduct(id);
    if (updated != null && mounted) setState(() => _product = updated);
    await _reloadHistory();
  }

  Future<void> _reloadHistory() async {
    final id = _product.id;
    if (id == null) return;
    setState(() {
      _movementHistory = context.read<InventoryProvider>().getProductMovements(
        id,
      );
    });
    await _movementHistory;
  }

  Future<void> _openMovement(MovementType type) async {
    final movement = await MovementDialog.show(
      context,
      product: _product,
      initialType: type,
    );
    if (movement == null || !mounted) return;
    final id = await context.read<InventoryProvider>().registerMovement(
      movement,
    );
    if (!mounted) return;
    if (id != null) {
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Movimiento registrado.'),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.read<InventoryProvider>().errorMessage ??
                      'No se pudo registrar el movimiento.',
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _editProduct() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductFormView(product: _product)),
    );
    if (changed == true && mounted) await _refresh();
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: colorsFor(context).error,
        ),
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Quieres eliminar “${_product.nombre}”? También se borrará su historial de movimientos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await context.read<InventoryProvider>().deleteProduct(
      _product.id!,
    );
    if (!mounted) return;
    if (deleted == true) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Producto eliminado.'),
            ],
          ),
        ),
      );
    }
  }
}

ColorScheme colorsFor(BuildContext context) => Theme.of(context).colorScheme;

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _NoMovementsCard extends StatelessWidget {
  const _NoMovementsCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Este producto aún no tiene movimientos.'),
          ),
        ],
      ),
    ),
  );
}
