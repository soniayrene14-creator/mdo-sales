import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../providers/proformas/proformas_notifier.dart';
import '../../providers/proformas/proformas_state.dart';
import '../../widgets/app_snack_bar.dart';

class ProformaDetailScreen extends ConsumerWidget {
  final int id;

  const ProformaDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proformasState = ref.watch(proformasNotifierProvider);

    ref.listen<ProformasState>(proformasNotifierProvider, (previous, next) {
      if (previous?.selectedProforma?.id != id && next.selectedProforma?.id != id) {
        ref.read(proformasNotifierProvider.notifier).loadProformaDetail(id);
      }
    });

    final proforma = proformasState.selectedProforma?.id == id ? proformasState.selectedProforma : null;

    if (proforma == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la proforma')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(proforma.proformaNumber),
        actions: [
          IconButton(
            onPressed: () async {
              final res = await ref
                  .read(documentDownloadServiceProvider)
                  .downloadAndOpen(path: '/api/v1/proformas/$id/pdf/', fileName: '${proforma.proformaNumber}.pdf');

              if (res.isFailure) {
                AppSnackBar.showError(res.error.toString());
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
            Text('Client : ${proforma.customerName ?? '-'}'),
            Text('Téléphone : ${proforma.customerPhone ?? '-'}'),
            const SizedBox(height: AppSizes.padding),
            const Text('Articles', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.padding / 2),
            if (proforma.items.isEmpty)
              const Text('Aucun article')
            else
              ...proforma.items.map(
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
                Text(
                  CurrencyFormatter.format(proforma.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
