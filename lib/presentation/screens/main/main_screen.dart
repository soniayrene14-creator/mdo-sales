import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../providers/main/main_notifier.dart';
import '../welcome/welcome_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(mainNotifierProvider.notifier).initMainProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = ref.watch(mainNotifierProvider.select((p) => p.isLoaded));
    final isHasInternet = ref.watch(mainNotifierProvider.select((p) => p.isHasInternet));
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));

    // Display RootScreen when data is being load
    if (!isLoaded) {
      return const WelcomeScreen();
    }

    // User data might still null for the first time app open or login without internet connection
    // So, throw error with a first time internet error message then the [ErrorScreen] will be shown
    if (isLoaded && user == null && !isHasInternet) {
      throw Exception(
        'Aucune connexion internet ! Une connexion internet est requise pour la première ouverture de l\'application ou la connexion utilisateur',
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_rounded),
            label: 'Vendre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Compte',
          ),
        ],
        currentIndex: _calculateSelectedIndex(),
        onTap: (int idx) => _onItemTapped(idx),
      ),
    );
  }

  int _calculateSelectedIndex() {
    final String location = ref.read(appRoutesProvider).router.state.uri.path;

    if (location.startsWith('/dashboard')) {
      return 0;
    }

    if (location.startsWith('/home')) {
      return 1;
    }

    if (location.startsWith('/products')) {
      return 2;
    }

    if (location.startsWith('/transactions')) {
      return 3;
    }

    if (location.startsWith('/account')) {
      return 4;
    }

    return 0;
  }

  void _onItemTapped(int index) {
    final router = ref.read(appRoutesProvider).router;
    final isAdmin = ref.read(mainNotifierProvider).user?.isAdmin ?? false;

    switch (index) {
      case 0:
        router.go(isAdmin ? '/dashboard' : '/dashboard-employee');
      case 1:
        router.go('/home');
      case 2:
        router.go('/products');
      case 3:
        router.go('/transactions');
      case 4:
        router.go('/account');
    }
  }
}
