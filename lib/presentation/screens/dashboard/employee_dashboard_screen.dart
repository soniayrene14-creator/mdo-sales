import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/dashboard/dashboard_notifier.dart';
import '../../widgets/app_mini_card.dart';
import '../../widgets/app_stat_card.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  ConsumerState<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends ConsumerState<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).loadEmployeeDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeDashboard = ref.watch(dashboardNotifierProvider.select((s) => s.employeeDashboard));

    if (employeeDashboard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tableau de bord employé')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord employé')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadEmployeeDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppMiniCard(
                    title: 'Produits',
                    value: '${employeeDashboard.nombreProduits}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: AppSizes.padding),
                  AppMiniCard(
                    title: 'Catégories',
                    value: '${employeeDashboard.nombreCategories}',
                    icon: Icons.category_rounded,
                    color: AppColors.cyan,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.padding * 2),
              AppStatCard(
                title: 'Mes ventes du jour',
                value: '${employeeDashboard.mesVentesDuJour}',
                icon: Icons.point_of_sale_rounded,
                color: AppColors.green,
              ),
              const SizedBox(height: AppSizes.padding),
              AppStatCard(
                title: 'Mon chiffre d\'affaires',
                value: '${employeeDashboard.monChiffreAffairesJour}',
                icon: Icons.attach_money_rounded,
                color: AppColors.blue,
              ),
              const SizedBox(height: AppSizes.padding),
              AppStatCard(
                title: 'Mes proformas',
                value: '${employeeDashboard.mesProformas}',
                icon: Icons.description_rounded,
                color: AppColors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
