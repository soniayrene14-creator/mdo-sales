import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/sale_entity.dart';
import '../../providers/sales/sales_notifier.dart';
import '../../providers/sales/sales_state.dart';

class SaleDetailScreen extends ConsumerWidget {
  final int id;

  const SaleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesNotifierProvider);

    ref.listen<SalesState>(salesNotifierProvider, (previous, next) {
      if (previous?.selectedSale?.id != id && next.selectedSale?.id != id) {
        ref.read(salesNotifierProvider.notifier).loadSaleDetail(id);
      }
    });

    final sale = salesState.selectedSale?.id == id ? salesState.selectedSale : null;

    if (sale == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la vente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sale.saleNumber),
        actions: [
          IconButton(
            onPressed: () async {
              final url = '${Constants.baseUrl}/api/v1/sales/$id/invoice/';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client : ${sale.customerName ?? '-'}'),
            Text('Téléphone : ${sale.customerPhone ?? '-'}'),
            Text('Paiement : ${sale.paymentMethod}'),
            const SizedBox(height: AppSizes.padding),
            const Text('Articles', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.padding / 2),
            if (sale.items.isEmpty)
              const Text('Aucun article')
            else
              ...sale.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.productName)),
                      Text('x${item.quantity}'),
                      Text(CurrencyFormatter.format(item.subtotal)),
                    ],
                  ),
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(CurrencyFormatter.format(sale.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
