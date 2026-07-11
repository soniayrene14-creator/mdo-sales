import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/sale_entity.dart';
import '../../providers/sales/sales_notifier.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesNotifierProvider.notifier).loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ventes')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(salesNotifierProvider.notifier).loadSales(),
        child: salesState.isLoading && salesState.sales == null
            ? const Center(child: CircularProgressIndicator())
            : salesState.sales == null || salesState.sales!.isEmpty
            ? const Center(child: Text('Aucune vente trouvée'))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.padding),
                itemCount: salesState.sales!.length,
                itemBuilder: (context, index) {
                  final sale = salesState.sales![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.padding),
                    child: ListTile(
                      title: Text(sale.saleNumber),
                      subtitle: Text('${sale.customerName ?? '-'} • ${sale.paymentMethod}'),
                      trailing: Text(CurrencyFormatter.format(sale.totalAmount)),
                      onTap: () {
                        context.push('/sales/sale-detail/${sale.id}');
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
