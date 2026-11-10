import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/product_model.dart';
import '../../../providers/inventory_provider.dart';
import '../product_detail_view.dart';
import 'movement_dialog.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stockState = _stockState(product);
    final currency = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$ ',
      decimalDigits: 0,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailView(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 11),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${product.categoria} · ${product.codigoSku}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StockBadge(state: stockState),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern('es_CO').format(product.cantidad)} uds.',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: stockState.color,
                                height: 1,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Mínimo ${product.stockMinimo} · ${currency.format(product.precio)} c/u',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _showMovementDialog(context),
                    icon: const Icon(Icons.swap_vert_rounded, size: 18),
                    label: const Text('Movimiento'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMovementDialog(BuildContext context) async {
    final result = await MovementDialog.show(context, product: product);
    if (result == null || !context.mounted) return;
    final id = await context.read<InventoryProvider>().registerMovement(result);
    if (!context.mounted) return;
    final message = id == null
        ? context.read<InventoryProvider>().errorMessage ??
              'No se pudo registrar el movimiento.'
        : 'Movimiento registrado correctamente.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: id == null
            ? Theme.of(context).colorScheme.error
            : const Color(0xFF246B4A),
        content: Row(
          children: [
            Icon(
              id == null
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _StockState {
  const _StockState(this.label, this.color, this.background);

  final String label;
  final Color color;
  final Color background;
}

_StockState _stockState(ProductModel product) {
  if (product.cantidad == 0) {
    return const _StockState('Agotado', AppColors.danger, Color(0xFFFCE8E6));
  }
  if (product.cantidad <= product.stockMinimo) {
    return const _StockState(
      'Cr\u00edtico',
      AppColors.danger,
      Color(0xFFFCE8E6),
    );
  }
  final warningLimit =
      product.stockMinimo +
      (product.stockMinimo * 0.5).ceil().clamp(1, 1000000);
  if (product.stockMinimo > 0 && product.cantidad <= warningLimit) {
    return const _StockState('Moderado', AppColors.warning, Color(0xFFFFF2DB));
  }
  return const _StockState('\u00d3ptimo', AppColors.success, Color(0xFFE6F4EA));
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.state});

  final _StockState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: state.background,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      state.label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: state.color, fontWeight: FontWeight.w800),
    ),
  );
}
