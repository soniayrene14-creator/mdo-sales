import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/dashboard/dashboard_notifier.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).loadAdminDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminDashboard = ref.watch(dashboardNotifierProvider.select((s) => s.adminDashboard));

    if (adminDashboard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tableau de bord administrateur')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord administrateur')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadAdminDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(context, 'Chiffre d\'affaires (jour)', '${adminDashboard.chiffreAffairesJour}'),
              const SizedBox(height: AppSizes.padding),
              _buildStatCard(context, 'Chiffre d\'affaires (semaine)', '${adminDashboard.chiffreAffairesSemaine}'),
              const SizedBox(height: AppSizes.padding),
              _buildStatCard(context, 'Chiffre d\'affaires (mois)', '${adminDashboard.chiffreAffairesMois}'),
              const SizedBox(height: AppSizes.padding * 2),
              Row(
                children: [
                  _buildMiniCard(context, 'Produits', '${adminDashboard.nombreProduits}'),
                  const SizedBox(width: AppSizes.padding),
                  _buildMiniCard(context, 'Employés', '${adminDashboard.nombreEmployes}'),
                ],
              ),
              const SizedBox(height: AppSizes.padding),
              Row(
                children: [
                  _buildMiniCard(context, 'Rupture', '${adminDashboard.produitsEnRupture}'),
                  const SizedBox(width: AppSizes.padding),
                  _buildMiniCard(context, 'Stock faible', '${adminDashboard.produitsStockFaible}'),
                ],
              ),
              const SizedBox(height: AppSizes.padding * 2),
              _buildStatCard(context, 'Nombre de ventes', '${adminDashboard.nombreVentes}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      width: double.infinity,
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
    );
  }

  Widget _buildMiniCard(BuildContext context, String title, String value) {
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
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
