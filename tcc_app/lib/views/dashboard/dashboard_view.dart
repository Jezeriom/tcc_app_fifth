import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, this.onOpenCatalog, this.onOpenHistory});

  final VoidCallback? onOpenCatalog;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventory, _) {
        final summary = inventory.resumen;
        final currency = NumberFormat.currency(
          locale: 'es_CO',
          symbol: r'$ ',
          decimalDigits: 0,
        );
        return RefreshIndicator(
          onRefresh: inventory.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const _WelcomeBanner(),
              const SizedBox(height: 20),
              if (inventory.hasError) ...[
                _ErrorBanner(message: inventory.errorMessage!),
                const SizedBox(height: 16),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1100
                      ? 4
                      : constraints.maxWidth >= 650
                      ? 2
                      : 1;
                  final cardWidth =
                      (constraints.maxWidth - 14 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      KpiCard(
                        width: cardWidth,
                        title: 'Total de productos',
                        value: '${summary.totalProductos}',
                        subtitle: 'Referencias activas',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                      KpiCard(
                        width: cardWidth,
                        title: 'Unidades físicas',
                        value: NumberFormat.decimalPattern('es_CO')
                            .format(summary.totalUnidades),
                        subtitle: 'Unidades disponibles',
                        icon: Icons.widgets_outlined,
                        color: const Color(0xFF426B9A),
                      ),
                      KpiCard(
                        width: cardWidth,
                        title: 'Valorización financiera',
                        value: currency.format(summary.valorTotal),
                        subtitle: 'Valor del stock actual',
                        icon: Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF7556A5),
                      ),
                      KpiCard(
                        width: cardWidth,
                        title: 'Stock crítico',
                        value: '${summary.productosBajoStock}',
                        subtitle: 'Productos en nivel mínimo',
                        icon: Icons.warning_amber_rounded,
                        color: summary.productosBajoStock > 0
                            ? AppColors.danger
                            : AppColors.success,
                        alert: summary.productosBajoStock > 0,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 26),
              _SectionHeading(
                title: 'Atención de inventario',
                trailing: TextButton.icon(
                  onPressed: () => _openCriticalCatalog(context, inventory),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Ver catálogo'),
                ),
              ),
              const SizedBox(height: 12),
              if (inventory.isLoading &&
                  inventory.productosStockCritico.isEmpty)
                const LinearProgressIndicator()
              else if (inventory.productosStockCritico.isEmpty)
                const _AllClearCard()
              else
                ...inventory.productosStockCritico
                    .take(4)
                    .map(
                      (product) => _CriticalProductTile(
                        product: product,
                        onTap: () => _openCriticalCatalog(context, inventory),
                      ),
                    ),
              const SizedBox(height: 24),
              _SectionHeading(title: 'Accesos rápidos'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final half = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        width: constraints.maxWidth < 450
                            ? constraints.maxWidth
                            : half,
                        icon: Icons.search_rounded,
                        title: 'Buscar productos',
                        subtitle: 'Consulta el catálogo',
                        onTap: onOpenCatalog,
                      ),
                      _QuickAction(
                        width: constraints.maxWidth < 450
                            ? constraints.maxWidth
                            : half,
                        icon: Icons.history_rounded,
                        title: 'Ver movimientos',
                        subtitle: 'Revisa entradas y salidas',
                        onTap: onOpenHistory,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCriticalCatalog(BuildContext context, InventoryProvider inventory) {
    unawaited(_applyCriticalFilter(inventory));
  }

  Future<void> _applyCriticalFilter(InventoryProvider inventory) async {
    await inventory.clearProductFilters();
    await inventory.setLowStockOnly(true);
    onOpenCatalog?.call();
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.alert = false,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 21),
                  ),
                  const Spacer(),
                  if (alert)
                    Icon(Icons.trending_up_rounded, color: color, size: 19),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: alert ? color : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Buenos días'
        : now.hour < 19
        ? 'Buenas tardes'
        : 'Buenas noches';
    final today = DateFormat('EEEE, d MMMM yyyy', 'es_CO').format(now);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100B1F1D),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tu inventario, en perspectiva',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  today,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 30,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalProductTile extends StatelessWidget {
  const _CriticalProductTile({required this.product, this.onTap});

  final ProductModel product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.danger.withValues(alpha: 0.1),
          foregroundColor: AppColors.danger,
          child: const Icon(Icons.priority_high_rounded),
        ),
        title: Text(
          product.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${product.categoria} · Mínimo ${product.stockMinimo}'),
        trailing: Text(
          '${product.cantidad} uds.',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: colors.error, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _AllClearCard extends StatelessWidget {
  const _AllClearCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todo en orden. No hay productos bajo el mínimo.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      ?trailing,
    ],
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
