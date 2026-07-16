import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/dashboard/dashboard_notifier.dart';
import '../../widgets/app_mini_card.dart';
import '../../widgets/app_stat_card.dart';

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
              AppStatCard(
                title: 'Chiffre d\'affaires (jour)',
                value: '${adminDashboard.chiffreAffairesJour}',
                icon: Icons.today_rounded,
                color: AppColors.blue,
              ),
              const SizedBox(height: AppSizes.padding),
              AppStatCard(
                title: 'Chiffre d\'affaires (semaine)',
                value: '${adminDashboard.chiffreAffairesSemaine}',
                icon: Icons.date_range_rounded,
                color: AppColors.purple,
              ),
              const SizedBox(height: AppSizes.padding),
              AppStatCard(
                title: 'Chiffre d\'affaires (mois)',
                value: '${adminDashboard.chiffreAffairesMois}',
                icon: Icons.calendar_month_rounded,
                color: AppColors.cyan,
              ),
              const SizedBox(height: AppSizes.padding * 2),
              Row(
                children: [
                  AppMiniCard(
                    title: 'Produits',
                    value: '${adminDashboard.nombreProduits}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: AppSizes.padding),
                  AppMiniCard(
                    title: 'Employés',
                    value: '${adminDashboard.nombreEmployes}',
                    icon: Icons.badge_rounded,
                    color: AppColors.zamp,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.padding),
              Row(
                children: [
                  AppMiniCard(
                    title: 'Rupture',
                    value: '${adminDashboard.produitsEnRupture}',
                    icon: Icons.remove_circle_rounded,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: AppSizes.padding),
                  AppMiniCard(
                    title: 'Stock faible',
                    value: '${adminDashboard.produitsStockFaible}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.yellow,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.padding * 2),
              AppStatCard(
                title: 'Nombre de ventes',
                value: '${adminDashboard.nombreVentes}',
                icon: Icons.point_of_sale_rounded,
                color: AppColors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
