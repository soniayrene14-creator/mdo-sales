import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/sales_report_entity.dart';
import '../../providers/dashboard/dashboard_notifier.dart';
import '../../providers/dashboard/dashboard_state.dart';
import '../../widgets/app_button.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);

    ref.listen<DashboardState>(dashboardNotifierProvider, (previous, next) {
      if (previous?.salesReport == null && next.salesReport == null && _startDate != null) {
        _loadReport();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rapport des ventes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Date de début',
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                        _loadReport();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.padding),
                Expanded(
                  child: AppButton(
                    text: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Date de fin',
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _endDate = picked);
                        _loadReport();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.padding * 2),
            if (dashboardState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardState.salesReport != null) ...[
              _buildReportCard(context, 'Période', dashboardState.salesReport!.periode),
              _buildReportCard(context, 'Nombre de ventes', '${dashboardState.salesReport!.nombreVentes}'),
              _buildReportCard(
                context,
                'Chiffre d\'affaires total',
                CurrencyFormatter.format(dashboardState.salesReport!.chiffreAffairesTotal),
              ),
              const SizedBox(height: AppSizes.padding),
              const Text('Répartition par paiement', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.padding / 2),
              if (dashboardState.salesReport!.repartitionParPaiement.isEmpty)
                const Text('Aucune donnée')
              else
                ...dashboardState.salesReport!.repartitionParPaiement.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item['payment_method']?.toString() ?? '-')),
                        Text(item['count']?.toString() ?? '0'),
                        Text(CurrencyFormatter.format(int.tryParse(item['total']?.toString() ?? '0') ?? 0)),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _loadReport() {
    if (_startDate == null || _endDate == null) return;
    final start = DateFormat('yyyy-MM-dd').format(_startDate!);
    final end = DateFormat('yyyy-MM-dd').format(_endDate!);
    ref.read(dashboardNotifierProvider.notifier).loadSalesReport(start: start, end: end);
  }

  Widget _buildReportCard(BuildContext context, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.padding),
      margin: const EdgeInsets.only(bottom: AppSizes.padding),
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
    );
  }
}
