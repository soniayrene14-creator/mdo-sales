import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/products_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import 'components/products_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsNotifierProvider.notifier).getAllProducts();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final notifier = ref.read(productsNotifierProvider.notifier);
    switch (_tabController.index) {
      case 1:
        notifier.getLowStockProducts();
        break;
      case 2:
        notifier.getOutOfStockProducts();
        break;
      case 3:
        notifier.getInactiveProducts();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'Stock faible'),
            Tab(text: 'Rupture de stock'),
            Tab(text: 'Inactifs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllProductsTab(),
          _LowStockTab(),
          _OutOfStockTab(),
          _InactiveTab(),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Ajouter un produit',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => context.go('/products/product-create'),
      ),
    );
  }
}

class _AllProductsTab extends ConsumerStatefulWidget {
  const _AllProductsTab();

  @override
  ConsumerState<_AllProductsTab> createState() => _AllProductsTabState();
}

class _AllProductsTabState extends ConsumerState<_AllProductsTab> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final productsState = ref.read(productsNotifierProvider);

    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref
          .read(productsNotifierProvider.notifier)
          .getAllProducts(
            offset: productsState.allProducts?.length,
            contains: searchFieldController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productsNotifierProvider.select((s) => s.allProducts));
    final isLoadingMore = ref.watch(productsNotifierProvider.select((s) => s.isLoadingMore));

    return RefreshIndicator(
      onRefresh: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
      displacement: 60,
      child: Scrollbar(
        child: CustomScrollView(
          controller: scrollController,
          // Disable scroll when data is null or empty
          physics: (allProducts?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              collapsedHeight: 70,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                child: _SearchField(controller: searchFieldController),
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, _) {
                if (allProducts == null) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: AppProgressIndicator(),
                  );
                }

                if (allProducts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: AppEmptyState(
                      subtitle: 'Aucun produit disponible, ajoutez un produit pour continuer',
                      buttonText: 'Ajouter un produit',
                      onTapButton: () => context.push('/products/product-create'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1 / 1.5,
                      crossAxisSpacing: AppSizes.padding / 2,
                      mainAxisSpacing: AppSizes.padding / 2,
                    ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, i) {
                      return _ProductCard(product: allProducts[i]);
                    },
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: AppLoadingMoreIndicator(isLoading: isLoadingMore),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTextField(
      controller: controller,
      hintText: 'Rechercher des produits...',
      type: AppTextFieldType.search,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        ref.read(productsNotifierProvider.notifier).resetProducts();
        ref.read(productsNotifierProvider.notifier).getAllProducts(contains: controller.text);
      },
      onTapClearButton: () {
        ref.read(productsNotifierProvider.notifier).getAllProducts(contains: controller.text);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductsCard(
      product: product,
      onTap: () => context.go('/products/product-detail/${product.id}'),
    );
  }
}

class _LowStockTab extends ConsumerWidget {
  const _LowStockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsNotifierProvider.select((s) => s.lowStockProducts));
    final isLoading = ref.watch(productsNotifierProvider.select((s) => s.isLoadingTab));

    return _ProductAlertList(
      products: products,
      isLoading: isLoading,
      emptySubtitle: 'Aucun produit en stock faible',
      onRefresh: () => ref.read(productsNotifierProvider.notifier).getLowStockProducts(),
    );
  }
}

class _OutOfStockTab extends ConsumerWidget {
  const _OutOfStockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsNotifierProvider.select((s) => s.outOfStockProducts));
    final isLoading = ref.watch(productsNotifierProvider.select((s) => s.isLoadingTab));

    return _ProductAlertList(
      products: products,
      isLoading: isLoading,
      emptySubtitle: 'Aucun produit en rupture de stock',
      onRefresh: () => ref.read(productsNotifierProvider.notifier).getOutOfStockProducts(),
    );
  }
}

class _InactiveTab extends ConsumerWidget {
  const _InactiveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsNotifierProvider.select((s) => s.inactiveProducts));
    final isLoading = ref.watch(productsNotifierProvider.select((s) => s.isLoadingTab));

    return _ProductAlertList(
      products: products,
      isLoading: isLoading,
      emptySubtitle: 'Aucun produit désactivé',
      onRefresh: () => ref.read(productsNotifierProvider.notifier).getInactiveProducts(),
      showReactivateAction: true,
    );
  }
}

class _ProductAlertList extends ConsumerWidget {
  final List<ProductEntity>? products;
  final bool isLoading;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final bool showReactivateAction;

  const _ProductAlertList({
    required this.products,
    required this.isLoading,
    required this.emptySubtitle,
    required this.onRefresh,
    this.showReactivateAction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && products == null) {
      return const AppProgressIndicator();
    }

    if (products == null || products!.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: AppEmptyState(subtitle: emptySubtitle),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.padding),
        itemCount: products!.length,
        itemBuilder: (context, index) {
          final product = products![index];

          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.padding / 2),
            child: ListTile(
              onTap: () => context.push('/products/product-detail/${product.id}'),
              title: Text(product.name),
              subtitle: Text('Stock : ${product.stock}'),
              trailing: showReactivateAction
                  ? TextButton(
                      onPressed: () => _reactivate(context, ref, product),
                      child: const Text('Réactiver'),
                    )
                  : Text(product.stockStatus ?? ''),
            ),
          );
        },
      ),
    );
  }

  Future<void> _reactivate(BuildContext context, WidgetRef ref, ProductEntity product) async {
    final res = await AppDialog.showProgress(() {
      return ref.read(productsNotifierProvider.notifier).reactivateProduct(product.id!);
    });

    if (res.isSuccess) {
      AppSnackBar.show('${product.name} réactivé');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }
}
