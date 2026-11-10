import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/inventory_provider.dart';
import 'product_form_view.dart';
import 'widgets/product_card.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<InventoryProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventory, _) {
        final colors = Theme.of(context).colorScheme;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Catálogo de productos',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProductFormView(),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Busca, filtra y revisa el nivel de existencias.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: inventory.setSearchQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, SKU o descripción',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _searchController.clear();
                                inventory.setSearchQuery('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: inventory.selectedCategory == null,
                            label: Text(
                              'Todas · ${inventory.resumen.totalProductos}',
                            ),
                            onSelected: (_) => inventory.setCategory(null),
                          ),
                        ),
                        ...inventory.categorias.map((category) {
                          final count =
                              inventory.conteoPorCategoria[category] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: inventory.selectedCategory == category,
                              label: Text('$category · $count'),
                              onSelected: (_) => inventory.setCategory(
                                inventory.selectedCategory == category
                                    ? null
                                    : category,
                              ),
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: inventory.lowStockOnly,
                            avatar: Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: inventory.lowStockOnly
                                  ? colors.onSecondaryContainer
                                  : colors.error,
                            ),
                            label: Text(
                              'Stock bajo · ${inventory.resumen.productosBajoStock}',
                            ),
                            onSelected: inventory.setLowStockOnly,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (inventory.isLoading)
              const LinearProgressIndicator(minHeight: 2),
            if (inventory.hasError)
              MaterialBanner(
                content: Text(inventory.errorMessage!),
                leading: Icon(Icons.error_outline, color: colors.error),
                actions: [
                  TextButton(
                    onPressed: inventory.refresh,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(
              child: inventory.productos.isEmpty
                  ? _EmptyCatalog(
                      hasFilters:
                          inventory.searchQuery.isNotEmpty ||
                          inventory.selectedCategory != null ||
                          inventory.lowStockOnly,
                      onClear: inventory.clearProductFilters,
                    )
                  : RefreshIndicator(
                      onRefresh: inventory.refresh,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1100
                              ? 3
                              : constraints.maxWidth >= 700
                              ? 2
                              : 1;
                          if (columns == 1) {
                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              itemCount: inventory.productos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => ProductCard(
                                product: inventory.productos[index],
                              ),
                            );
                          }
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 190,
                                ),
                            itemCount: inventory.productos.length,
                            itemBuilder: (context, index) => ProductCard(
                              product: inventory.productos[index],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.hasFilters, required this.onClear});

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'No encontramos productos' : 'Tu catálogo está vacío',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            hasFilters
                ? 'Prueba cambiando los filtros de búsqueda.'
                : 'Los productos que registres aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    ),
  );
}
