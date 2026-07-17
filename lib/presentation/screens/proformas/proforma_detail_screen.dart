import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../providers/proformas/proformas_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';

class ProformaDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const ProformaDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ProformaDetailScreen> createState() => _ProformaDetailScreenState();
}

class _ProformaDetailScreenState extends ConsumerState<ProformaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proformasNotifierProvider.notifier).loadProformaDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final proformasState = ref.watch(proformasNotifierProvider);
    final proforma = proformasState.selectedProforma?.id == widget.id ? proformasState.selectedProforma : null;

    if (proforma == null && proformasState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la proforma')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppErrorWidget(message: proformasState.error),
              const SizedBox(height: AppSizes.padding),
              AppButton(
                text: 'Réessayer',
                width: 160,
                onTap: () => ref.read(proformasNotifierProvider.notifier).loadProformaDetail(widget.id),
              ),
            ],
          ),
        ),
      );
    }

    if (proforma == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la proforma')),
        body: const Center(child: AppProgressIndicator()),
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
                  .downloadAndOpen(
                    path: '/api/v1/proformas/${widget.id}/pdf/',
                    fileName: '${proforma.proformaNumber}.pdf',
                  );

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}'),
                          Text(CurrencyFormatter.format(item.subtotal)),
                        ],
                      ),
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
