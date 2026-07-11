import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/stock/stock_notifier.dart';
import '../../providers/stock/stock_state.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_text_field.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockNotifierProvider.notifier).loadOverview();
      ref.read(stockNotifierProvider.notifier).loadMovements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Mouvements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(stockState: stockState),
          _MovementsTab(stockState: stockState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdjustmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context) {
    if (ref.read(productsNotifierProvider).allProducts == null) {
      ref.read(productsNotifierProvider.notifier).getAllProducts();
    }

    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    int? selectedProductId;

    AppDialog.show(
      title: 'Ajuster le stock',
      child: Consumer(
        builder: (context, ref, _) {
          final products = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDropDown<int>(
                labelText: 'Produit',
                hintText: 'Sélectionner un produit',
                dropdownItems: products.map((product) {
                  return DropdownMenuItem<int>(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) => selectedProductId = value,
              ),
              const SizedBox(height: AppSizes.padding),
              AppTextField(
                controller: quantityController,
                labelText: 'Quantité',
                hintText: 'Positif pour réapprovisionner, négatif pour diminuer',
                keyboardType: const TextInputType.numberWithOptions(signed: true),
              ),
              const SizedBox(height: AppSizes.padding),
              AppTextField(
                controller: reasonController,
                labelText: 'Raison',
                hintText: 'Raison optionnelle',
              ),
            ],
          );
        },
      ),
      rightButtonText: 'Enregistrer',
      onTapRightButton: (context) async {
        final quantity = int.tryParse(quantityController.text.trim());
        if (selectedProductId == null || quantity == null || quantity == 0) return;

        final res = await ref
            .read(stockNotifierProvider.notifier)
            .adjustStock(
              selectedProductId!,
              quantity,
              reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
            );

        if (res.isSuccess) {
          if (!context.mounted) return;
          Navigator.of(context).pop();
        } else {
          AppDialog.showError(error: res.error?.toString() ?? 'Échec de l\'ajustement du stock');
        }
      },
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final StockState stockState;

  const _OverviewTab({required this.stockState});

  @override
  Widget build(BuildContext context) {
    final overview = stockState.overview;

    if (stockState.isLoading && overview == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (overview == null) {
      return const Center(child: Text('Aucune donnée de stock'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatCard(title: 'Total', value: '${overview.totalProducts}'),
              const SizedBox(width: AppSizes.padding),
              _StatCard(title: 'En stock', value: '${overview.enStock}'),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            children: [
              _StatCard(title: 'Stock faible', value: '${overview.stockFaible}'),
              const SizedBox(width: AppSizes.padding),
              _StatCard(title: 'Rupture', value: '${overview.rupture}'),
            ],
          ),
          const SizedBox(height: AppSizes.padding * 2),
          const Text(
            'Alertes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.padding),
          if (overview.alertes.isEmpty)
            const Text('Aucune alerte')
          else
            ...overview.alertes.map(
              (product) => Card(
                margin: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('Stock : ${product.stock}'),
                  trailing: Text(product.stockStatus ?? ''),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MovementsTab extends StatelessWidget {
  final StockState stockState;

  const _MovementsTab({required this.stockState});

  @override
  Widget build(BuildContext context) {
    final movements = stockState.movements;

    if (stockState.isLoading && movements == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movements == null || movements.isEmpty) {
      return const Center(child: Text('Aucun mouvement trouvé'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.padding / 2),
          child: ListTile(
            title: Text(movement.productName),
            subtitle: Text('${movement.movementType} • ${movement.quantity}'),
            trailing: Text(movement.createdAt ?? ''),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSizes.padding / 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
