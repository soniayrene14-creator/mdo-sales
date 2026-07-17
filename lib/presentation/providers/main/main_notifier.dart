import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/entities/queued_action_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../../../domain/usecases/queued_action_usecases.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../../widgets/app_snack_bar.dart';
import '../auth/auth_notifier.dart';
import '../products/products_notifier.dart';
import 'main_state.dart';

final mainNotifierProvider = NotifierProvider<MainNotifier, MainState>(
  MainNotifier.new,
);

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() {
    return const MainState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  Future<void> initMainProvider() async {
    await startPingService();
    await getAndSyncAllUserData();
  }

  Future<void> startPingService() async {
    final deviceInfoService = ref.read(deviceInfoServiceProvider);
    final pingService = ref.read(pingServiceProvider);

    // Note: The ICMP protocol may not work on virtual devices
    final isPhysicalDevice = await deviceInfoService.checkDeviceType();

    pingService.startPing(host: isPhysicalDevice ? '8.8.8.8' : '127.0.0.1');
    pingService.addConnectionStatusListener(
      (isConnected) => onHasInternet(isConnected),
    );
  }

  Future<void> checkAndSyncAllData() async {
    final pingService = ref.read(pingServiceProvider);

    // Prevent sync during first time app open
    if (!state.isLoaded || !pingService.isConnected) return;

    try {
      state = state.copyWith(isSyncronizing: true);

      // Execute all queued actions
      int queueExecutedCount = await executeAllQueuedActions();

      // Sync all data
      await getAndSyncAllUserData();

      if (queueExecutedCount > 0) {
        AppSnackBar.show("$queueExecutedCount file(s) d'attente exécutée(s)");
      }

      // Re-check queued actions
      checkIsHasQueuedActions();

      state = state.copyWith(isSyncronizing: false);
    } catch (e) {
      state = state.copyWith(isSyncronizing: false);
      AppSnackBar.showError('Échec de la synchronisation des données\n\n${e.toString()}');
    }
  }

  Future<void> getAndSyncAllUserData() async {
    final userId = _requireUserId();
    final userRepository = ref.read(userRepositoryProvider);
    final productRepository = ref.read(productRepositoryProvider);
    final transactionRepository = ref.read(transactionRepositoryProvider);

    // Run multiple futures simultaneously
    // GetMeUsecase (not GetUserUsecase) since /accounts/{id}/ is admin-only
    // and would 403 for an employee fetching their own account.
    var res = await Future.wait([
      GetMeUsecase(userRepository).call(NoParam()),
      SyncAllUserProductsUsecase(productRepository).call(userId),
      SyncAllUserTransactionsUsecase(transactionRepository).call(userId),
    ]);

    // Set and notify user state
    if (res.first.isSuccess) {
      state = state.copyWith(user: res.first.data as UserEntity?);
    }

    if (res[1].isFailure) AppSnackBar.showError("Échec de la synchronisation des produits");
    if (res[2].isFailure) AppSnackBar.showError("Échec de la synchronisation des transactions");

    // Refresh products list
    ref.read(productsNotifierProvider.notifier).getAllProducts();

    // Check queued actions
    checkIsHasQueuedActions();

    // Notify to MainScreen
    state = state.copyWith(isLoaded: true);
  }

  Future<int> executeAllQueuedActions() async {
    var queuedActions = await getQueuedActions();

    if (queuedActions.isNotEmpty) {
      final queuedActionRepository = ref.read(queuedActionRepositoryProvider);
      var res = await ExecuteAllQueuedActionUsecase(queuedActionRepository).call(queuedActions);

      int executedCount = res.data?.where((e) => e).length ?? 0;
      return executedCount;
    }

    return 0;
  }

  Future<List<QueuedActionEntity>> getQueuedActions() async {
    final queuedActionRepository = ref.read(queuedActionRepositoryProvider);
    var res = await GetAllQueuedActionUsecase(queuedActionRepository).call(NoParam());
    return res.data ?? [];
  }

  Future<void> onHasInternet(bool value) async {
    state = state.copyWith(isHasInternet: value);
    if (value) checkAndSyncAllData();
  }

  Future<void> checkIsHasQueuedActions() async {
    final isEmpty = (await getQueuedActions()).isEmpty;
    state = state.copyWith(isHasQueuedActions: isEmpty);
  }
}
