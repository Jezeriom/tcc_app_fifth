import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/movement_model.dart';
import '../../providers/inventory_provider.dart';

class MovementHistoryView extends StatelessWidget {
  const MovementHistoryView({super.key});

  @override
  Widget build(BuildContext context) => Consumer<InventoryProvider>(
    builder: (context, inventory, _) {
      final movements = inventory.movimientos;
      final net = movements.fold<int>(
        0,
        (balance, movement) =>
            balance +
            (movement.tipo == MovementType.ENTRADA
                ? movement.cantidad
                : -movement.cantidad),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de movimientos',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entradas, salidas y balance del período seleccionado.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SegmentedButton<MovementType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todas')),
                    ButtonSegment(
                      value: MovementType.ENTRADA,
                      label: Text('Entradas'),
                    ),
                    ButtonSegment(
                      value: MovementType.SALIDA,
                      label: Text('Salidas'),
                    ),
                  ],
                  selected: {inventory.movementTypeFilter},
                  onSelectionChanged: (selected) =>
                      inventory.setMovementType(selected.first),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DateFilterButton(
                      label: 'Desde',
                      date: inventory.movementDateFrom,
                      onSelected: (date) => inventory.setMovementDateRange(
                        date == null ? null : _startOfDay(date),
                        inventory.movementDateTo,
                      ),
                    ),
                    _DateFilterButton(
                      label: 'Hasta',
                      date: inventory.movementDateTo,
                      onSelected: (date) => inventory.setMovementDateRange(
                        inventory.movementDateFrom,
                        date == null ? null : _endOfDay(date),
                      ),
                    ),
                    if (inventory.movementDateFrom != null ||
                        inventory.movementDateTo != null)
                      ActionChip(
                        avatar: const Icon(
                          Icons.filter_alt_off_rounded,
                          size: 18,
                        ),
                        label: const Text('Quitar fechas'),
                        onPressed: () =>
                            inventory.setMovementDateRange(null, null),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _BalanceCard(net: net, count: movements.length),
          ),
          const SizedBox(height: 8),
          if (inventory.isMovementLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: movements.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        inventory.hasError
                            ? inventory.errorMessage!
                            : 'No hay movimientos en este período.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => inventory.loadMovements(
                      productId: null,
                      type: inventory.movementTypeFilter,
                      from: inventory.movementDateFrom,
                      to: inventory.movementDateTo,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: movements.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          MovementListTile(movement: movements[index]),
                    ),
                  ),
          ),
        ],
      );
    },
  );
}

class MovementListTile extends StatelessWidget {
  const MovementListTile({
    super.key,
    required this.movement,
    this.showProduct = true,
    this.productName,
  });

  final MovementModel movement;
  final bool showProduct;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    final isEntry = movement.tipo == MovementType.ENTRADA;
    final color = isEntry ? const Color(0xFF2E7D32) : const Color(0xFFB3261E);
    final date = DateFormat(
      'd MMM yyyy · HH:mm',
      'es_CO',
    ).format(movement.fecha);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          child: Icon(
            isEntry ? Icons.south_west_rounded : Icons.north_east_rounded,
          ),
        ),
        title: Text(
          '${isEntry ? 'Entrada' : 'Salida'}${showProduct ? ' · ${productName ?? 'Producto #${movement.idProducto}'}' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$date${movement.motivo.isEmpty ? '' : ' · ${movement.motivo}'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${isEntry ? '+' : '−'}${movement.cantidad}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.date,
    required this.onSelected,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('d MMM yyyy', 'es_CO');
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          cancelText: 'Cancelar',
          confirmText: 'Aplicar',
        );
        if (selected != null) onSelected(selected);
      },
      icon: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(date == null ? label : '$label · ${format.format(date!)}'),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.net, required this.count});

  final int net;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = net >= 0
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(Icons.swap_vert_rounded, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance neto',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text('$count movimientos en el período'),
                ],
              ),
            ),
            Text(
              '${net > 0 ? '+' : ''}$net uds.',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
